//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

public final class App {
           
    public let router: AppRouter
    
    public var validateAPIKey: ((_ apiKey: String) -> Bool)? {
        get { router.validateAPIKey }
        set { router.validateAPIKey = newValue }
    }
    
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
