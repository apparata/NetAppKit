//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

extension App {
    
    // MARK: - App Server
    
    public func listen(on port: Int = 4000,
                       host: String = "localhost",
                       backlog: Int = 256) throws {
        try server.listen(on: port, host: host, backlog: backlog)
    }
    
    // MARK: - App Router
    
    public func handle(_ method: HTTPMethod?, path: String?, action: @escaping RouteAction) {
        router.handle(method, path: path, action: action)
    }
}
