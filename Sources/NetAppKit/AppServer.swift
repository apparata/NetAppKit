//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public enum AppServerError: Error {
    case addressAlreadyInUse
    case underlying(Error)
}

public class AppServer {
    
    private var loopGroup: MultiThreadedEventLoopGroup
    
    private weak var router: AppRouter?
    
    public init(app: App,
                threadCount: Int = System.coreCount) {
        loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: threadCount)
        router = app.router
    }
    
    deinit {
        try? loopGroup.syncShutdownGracefully()
    }
    
    public func listen(on port: Int = 4000,
                       host: String = "localhost",
                       backlog: Int = 256) throws {
        do {
            let serverChannel = try bindServerChannel(to: host, on: port, backlog: backlog)
            log(public: "*** App server running on: \(serverChannel.localAddress!)")
            try waitUntilChannelCloses(serverChannel)
        } catch {
            throw mapError(error)
        }
    }
    
    private func bindServerChannel(to host: String,
                                   on port: Int,
                                   backlog: Int) throws -> Channel {
        let bootstrap = makeServerBootstrap(backlog: backlog)
        return try bootstrap.bind(host: host, port: port).wait()
    }
    
    private func waitUntilChannelCloses(_ channel: Channel) throws {
        try channel.closeFuture.wait()
    }
    
    private func makeServerBootstrap(backlog: Int) -> ServerBootstrap {
        let serverBootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: SocketOptionValue(backlog))
            .serverSocketOption(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
            .childChannelInitializer { [weak self] channel in
                return channel.pipeline.configureHTTPServerPipeline().flatMap { _ in
                    channel.pipeline.addHandler(ServerInboundHandler(channel: channel, router: self?.router))
                }
            }
            .childSocketOption(IPPROTO_TCP, TCP_NODELAY)
            .childSocketOption(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
        
        return serverBootstrap
    }

    private func mapError(_ error: Error) -> AppServerError {
        if let ioError = error as? IOError {
            switch ioError.errnoCode {
            case 48: // Address already in use
                return AppServerError.addressAlreadyInUse
            default:
                return AppServerError.underlying(ioError)
            }
        }
        return AppServerError.underlying(error)
    }
}
