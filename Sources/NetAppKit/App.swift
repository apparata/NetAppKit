//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public final class App {
       
    public let server: AppServer
    
    public let router: AppRouter
        
    private let loopGroup: MultiThreadedEventLoopGroup

    // MARK: - Life cycle
    
    public init() {
        loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        router = AppRouter()
        server = AppServer(loopGroup: loopGroup, router: router)
    }
    
    deinit {
        try! loopGroup.syncShutdownGracefully()
    }
}
