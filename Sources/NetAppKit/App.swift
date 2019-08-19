//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public final class App {
       
    public let server: AppServer
    
    public let router: AppRouter
    
    public let fileIO: FileIO
    
    private let loopGroup: MultiThreadedEventLoopGroup

    // MARK: - Life cycle
    
    public init() {
        loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        fileIO = FileIO()
        router = AppRouter()
        server = AppServer(loopGroup: loopGroup, router: router)
    }
    
    deinit {
        try! loopGroup.syncShutdownGracefully()
    }
}
