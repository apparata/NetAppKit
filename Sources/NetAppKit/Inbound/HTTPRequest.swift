//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIOHTTP1

public final class HTTPRequest {
    
    public let method: HTTPMethod
    public let uri: String
    public let headers: HTTPHeaders
    public let rawBody: DispatchData
    public let parameters: [String: String]
    
    internal init(head: HTTPRequestHead, body: DispatchData, parameters: [String: String] = [:]) {
        method = head.method
        uri = head.uri
        headers = head.headers
        rawBody = body
        self.parameters = parameters
    }
    
    private init(method: HTTPMethod,
                 uri: String,
                 headers: HTTPHeaders,
                 rawBody: DispatchData,
                 parameters: [String: String]) {
        self.method = method
        self.uri = uri
        self.headers = headers
        self.rawBody = rawBody
        self.parameters = parameters
    }
    
    internal func withParameters(_ parameters: [String: String]) -> HTTPRequest {
        return HTTPRequest(method: method,
                           uri: uri,
                           headers: headers,
                           rawBody: rawBody,
                           parameters: parameters)
    }
    
    public func parameter(_ name: String) -> String {
        return parameters[name] ?? ""
    }
}
