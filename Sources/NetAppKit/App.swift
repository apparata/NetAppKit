//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public final class App {
           
    public let router: AppRouter
    
    private var subapps: [App]
        
    // MARK: - Life cycle
    
    public init() {
        router = AppRouter()
        subapps = []
    }
    
    public func handle(_ method: HTTPMethod?, path: String?, action: @escaping RouteAction) {
        router.handle(method, path: path, action: action)
    }

    public func installSubapp(_ app: App, path: String) {
        subapps.append(app)
        router.installSubrouter(app.router, path: path)
    }
    
}
