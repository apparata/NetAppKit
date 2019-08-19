//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1

internal extension ServerBootstrap {
    
    func serverSocketOption(_ optionLevel: SocketOptionLevel, _ optionName: SocketOptionName, value: SocketOptionValue = 1) -> Self {
        childChannelOption(ChannelOptions.socket(optionLevel, optionName), value: value)
    }
    
    func childSocketOption(_ optionLevel: SocketOptionLevel, _ optionName: SocketOptionName, value: SocketOptionValue = 1) -> Self {
        childChannelOption(ChannelOptions.socket(optionLevel, optionName), value: value)
    }
}
