//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

/// The next action is called by the handler to allow other actions to
/// also handle this request.
public typealias NextAction = () -> Void

public typealias RouteAction = (HTTPRequest, HTTPResponse, NextAction) -> Void

private typealias RouteActionWrapper = (HTTPRequest, HTTPResponse, NextAction, PathMatcher) -> Void

public class AppRouter {
    
    private var handlers: [RouteActionWrapper] = []
    
    internal init() {
        //
    }
    
    /// Handle inbound requests matching the specified method and path.
    ///
    /// - parameter method: Match a particular HTTP method. `nil` matches any.
    /// - parameter path: Match a particular URI path. `nil` matches any path.
    /// - parameter action: The action to perform on the request.
    public func handle(_ method: HTTPMethod? = nil, path: String? = nil, action: @escaping RouteAction) {

        var pattern: PathPattern?

        if let path = path {
            do {
                pattern = try PathMatcher.makePattern(from: path)
            } catch {
                log(error: error)
                return
            }
        }

        handlers.append { (request, response, next, pathMatcher) in

            if let method = method, method != request.method {
                next()
                return
            }

            var parameters: [String: String] = [:]

            if let pattern = pattern {
                if let match = pathMatcher.match(with: pattern) {
                    parameters = match.parameters
                } else {
                    next()
                    return
                }
            }

            action(request.withParameters(parameters), response, next)
        }
    }
    
    internal func routeRequest(_ request: HTTPRequest, on channel: Channel) {

        let response = HTTPResponse(channel: channel)

        guard URL(string: request.uri)?.standardized != nil else {
            response.send("Resource not found.", status: 404)
            return
        }

        route(request: request, response: response, index: 0)
    }
    
    private func route(request: HTTPRequest, response: HTTPResponse, index: Int) {
        
        guard index < handlers.count else {
            response.send("Resource not found.", status: 404)
            return
        }
        
        guard let matcher = try? PathMatcher(path: request.uri) else {
            response.send("Bad request.", status: 400)
            return
        }
        
        handlers[index](request, response, {
            self.route(request: request, response: response, index: index + 1)
        }, matcher)
    }
}
