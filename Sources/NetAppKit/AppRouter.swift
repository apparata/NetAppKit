//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public enum RouterResult {
    case `handled`
    case `notHandled`
}

public typealias RouteAction = (HTTPRequest, HTTPResponse) -> RouterResult

private typealias RouteActionWrapper = (HTTPRequest, HTTPResponse, PathMatcher) -> RouterResult

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

        handlers.append { request, response, pathMatcher in

            if let method = method, method != request.method {
                return .notHandled
            }

            var parameters: [String: String] = [:]

            if let pattern = pattern {
                if let match = pathMatcher.match(with: pattern) {
                    parameters = match.parameters
                } else {
                    return .notHandled
                }
            }

            return action(request.withParameters(parameters), response)
        }
    }
    
    public func installSubrouter(_ router: AppRouter, path: String) {
        
        do {
            let pattern = try PathMatcher.makePattern(from: path)

            handlers.append { request, response, pathMatcher in
                return router.route(request: request,
                                    response: response,
                                    matcher: pathMatcher.appendingPrefix(pattern: pattern))
            }

        } catch {
            log(error: error)
        }
    }
    
    internal func routeRequest(_ request: HTTPRequest, on channel: Channel) {

        let response = HTTPResponse(channel: channel)

        guard URL(string: request.uri)?.standardized != nil else {
            response.send("Resource not found.", status: 404)
            return
        }
        
        guard let matcher = try? PathMatcher(path: request.uri) else {
            response.send("Bad request.", status: 400)
            return
        }

        let result = route(request: request, response: response, matcher: matcher)
        
        if result == .notHandled {
            response.send("Resource not found.", status: 404)
        }
    }
    
    private func route(request: HTTPRequest, response: HTTPResponse, matcher: PathMatcher) -> RouterResult {
        
        for handler in handlers {
            let result = handler(request, response, matcher)
            if result == .handled {
                return .handled
            }
        }
        
        return .notHandled
    }
}
