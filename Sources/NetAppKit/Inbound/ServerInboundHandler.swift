//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

internal final class ServerInboundHandler: ChannelInboundHandler {

    internal typealias InboundIn = HTTPServerRequestPart
    
    private let stateMachine = StateMachine<ServerInboundHandler>(initialState: .waitingForRequest)
    
    internal weak var channel: Channel?
    internal weak var router: AppRouter?
    
    internal init(channel: Channel, router: AppRouter?) {
        self.channel = channel
        self.router = router
        stateMachine.delegate = self
    }
    
    internal func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        switch unwrapInboundIn(data) {
            
        case .head(let head):
            stateMachine.fireEvent(.receivedHead(head))
        
        case .body(var buffer):
            let byteCount = buffer.readableBytes
            if byteCount > 0, let chunk = buffer.readDispatchData(length: byteCount) {
                stateMachine.fireEvent(.receivedBodyChunk(chunk))
            }
        
        case .end:
            stateMachine.fireEvent(.receivedEnd(context))
        }
    }
    
    internal func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    internal func errorCaught(context: ChannelHandlerContext, error: Error) {
        log(error: error)
    }
}

