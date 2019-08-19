//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

internal enum InboundState {
    case waitingForRequest
    case waitingForEndOfRequest(head: HTTPRequestHead, body: DispatchData)
    case processingRequest(HTTPRequest)
}

internal enum InboundEvent {
    case receivedHead(HTTPRequestHead)
    case receivedBodyChunk(DispatchData)
    case receivedEnd
    case processedRequest
}

extension ServerInboundHandler: StateMachineDelegate {
    
    internal typealias State = InboundState
    internal typealias Event = InboundEvent
    
    internal func stateToTransitionTo(from state: InboundState, dueTo event: InboundEvent) -> InboundState? {
        
        switch (state, event) {
            
        case (.waitingForRequest, .receivedHead(let head)):
            return .waitingForEndOfRequest(head: head, body: DispatchData.empty)
            
        case (.waitingForEndOfRequest(let head, var body), .receivedBodyChunk(let chunk)):
            body.append(chunk)
            return .waitingForEndOfRequest(head: head, body: body)
            
        case (.waitingForEndOfRequest(let head, let body), .receivedEnd):
            let request = HTTPRequest(head: head, body: body)
            return .processingRequest(request)
            
        case (.processingRequest, .processedRequest):
            return .waitingForRequest
            
        default:
            return nil
        }
    }
    
    internal func willTransition(from state: InboundState, to newState: InboundState, dueTo event: InboundEvent) {
        
    }
    
    internal func didTransition(from state: InboundState, to newState: InboundState, dueTo event: InboundEvent) {
        
        switch (state, event, newState) {
        case (_, _, .processingRequest(let request)):
            guard let channel = channel else {
                return
            }
            router?.routeRequest(request, on: channel)
            
        default:
            break
        }
    }
}
