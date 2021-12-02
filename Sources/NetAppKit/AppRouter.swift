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

public typealias RouteAction = (HTTPRequest, HTTPResponse) async -> RouterResult

private typealias RouteActionWrapper = (HTTPRequest, HTTPResponse, PathMatcher) async -> RouterResult

public class AppRouter {
    
    private var handlers: [RouteActionWrapper] = []
    
    public var validateAPIKey: ((_ apiKey: String) -> Bool)?
    
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
            
            if let components = URLComponents(string: request.uri) {
                for queryItem in components.queryItems ?? [] {
                    if let value = queryItem.value {
                        parameters[queryItem.name] = value
                    }
                }
            }

            return await action(request.withParameters(parameters), response)
        }
    }
    
    public func installSubrouter(_ router: AppRouter, path: String) {
        
        do {
            let pattern = try PathMatcher.makePattern(from: path)

            handlers.append { request, response, pathMatcher in
                return await router.route(request: request,
                                          response: response,
                                          matcher: pathMatcher.appendingPrefix(pattern: pattern))
            }

        } catch {
            log(error: error)
        }
    }
    
    internal func routeRequest(_ request: HTTPRequest, on channel: Channel) async {

        let response = HTTPResponse(channel: channel)
        
        guard URL(string: request.uri)?.standardized != nil else {
            response.send("Resource not found.", status: 404)
            return
        }
        
        guard let matcher = try? PathMatcher(path: request.uri) else {
            response.send("Bad request.", status: 400)
            return
        }

        let result = await route(request: request, response: response, matcher: matcher)
        
        if result == .notHandled {
            response.send("Resource not found.", status: 404)
        }
    }
    
    private func route(request: HTTPRequest, response: HTTPResponse, matcher: PathMatcher) async -> RouterResult {
        
        if let validateAPIKey = validateAPIKey {
            guard let apiKey = request.headers["API-Key"].first else {
                response.send("API key missing.", status: 401)
                return .handled
            }
            guard validateAPIKey(apiKey) else {
                response.send("Unauthorized API key.", status: 401)
                return .handled
            }
        }
        
        for handler in handlers {
            let result = await handler(request, response, matcher)
            if result == .handled {
                return .handled
            }
        }
        
        return .notHandled
    }
}
