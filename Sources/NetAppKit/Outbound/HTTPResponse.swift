//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public final class HTTPResponse {
    
    private enum State {
        case initial
        case sentHead
        case finished
    }
    
    private var state: State = .initial
    
    private weak var channel: Channel?
    
    internal init(channel: Channel) {
        self.channel = channel
    }
    
    public func sendJSON<T: Encodable>(_ encodable: T,
                                       status: Int = 200,
                                       headers: [(String, String)] = [],
                                       contentType: MIMEContentType? = .json) {
        let data = (try? JSONEncoder().encode(encodable)) ?? Data()
        send(data, status: status, headers: headers, contentType: contentType)
    }
    
    public func send(_ string: String,
                     status: Int = 200,
                     headers: [(String, String)] = [],
                     contentType: MIMEContentType? = .text) {
        send(string.data(using: .utf8) ?? Data(),
             status: status,
             headers: headers,
             contentType: contentType)
    }
    
    public func send(_ data: Data,
                     status: Int = 200,
                     headers: [(String, String)] = [],
                     contentType: MIMEContentType?) {
        
        guard let channel = channel else {
            return
        }

        guard state != .finished else {
            return
        }

        var bodyBuffer = channel.allocator.buffer(capacity: data.count)
        bodyBuffer.writeBytes(data)

        var httpHeaders = HTTPHeaders(headers)
        if let contentType = contentType {
            httpHeaders.replaceOrAdd(name: "Content-Type", value: contentType.asString)
        }
        httpHeaders.replaceOrAdd(name: "Content-Length", value: String(bodyBuffer.readableBytes))

        sendHead(status: status, headers: httpHeaders)

        let body = HTTPServerResponsePart.body(.byteBuffer(bodyBuffer))
        
        _ = channel
            .writeAndFlush(body)
            .recover { error in
                log(error: error)
                self.finishResponse()
            }
            .map {
                self.finishResponse()
            }
    }
        
    private func sendHead(status: Int, headers: HTTPHeaders) {
        guard let channel = channel else {
            return
        }
        guard state == .initial else {
            return
        }
        state = .sentHead
        
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: HTTPResponseStatus(statusCode: status),
                                    headers: headers)
        let headPart = HTTPServerResponsePart.head(head)
        _ = channel
            .writeAndFlush(headPart)
            .recover { error in
                log(error: error)
                self.finishResponse()
            }
    }
    
    private func finishResponse() {

        guard let channel = channel else {
            return
        }
        
        _ = channel
            .writeAndFlush(HTTPServerResponsePart.end(nil))
            .map { channel.close() }
    }
}
