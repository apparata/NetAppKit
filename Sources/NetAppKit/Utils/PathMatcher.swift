//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

internal struct PathPattern {
    
    internal enum Part {
        case string(String)
        case parameter(String)
    }
    
    internal let parts: [Part]
    
    fileprivate init(components: [String]) {
        parts = components.map {
            if $0.hasPrefix(":") {
                return .parameter(String($0.dropFirst()))
            } else {
                return .string($0)
            }
        }
    }
    
    private init(parts: [Part]) {
        self.parts = parts
    }
    
    fileprivate func appendingPattern(_ pattern: PathPattern) -> PathPattern {
        guard parts.count > 0 else {
            return pattern
        }
        var patternParts = pattern.parts
        if case let .string(part) = patternParts.first, part == "/" {
            patternParts.removeFirst()
        }
        return PathPattern(parts: parts + patternParts)
    }
}

internal struct PathMatch {
    
    internal let parameters: [String: String]
    
    fileprivate init(parameters: [String: String]) {
        self.parameters = parameters
    }
    
    internal subscript(name: String) -> String? {
        return parameters[name]
    }
}

internal class PathMatcher {
    
    internal let path: String
    internal let components: [String]
    internal let prefixPattern: PathPattern

    internal enum Error: Swift.Error {
        case invalidPath
    }
    
    internal static func makePattern(from path: String) throws -> PathPattern {

        guard let url = URL(string: path)?.standardized else {
            throw Error.invalidPath
        }

        return PathPattern(components: url.pathComponents)
    }
    
    internal init(path: String) throws {

        guard let url = URL(string: path)?.standardized else {
            throw Error.invalidPath
        }

        self.path = path
        components = url.pathComponents
        prefixPattern = PathPattern(components: [])
    }
    
    private init(path: String, components: [String], prefixPattern: PathPattern) {
        self.path = path
        self.components = components
        self.prefixPattern = prefixPattern
    }
    
    internal func appendingPrefix(pattern: PathPattern) -> PathMatcher {
        return PathMatcher(path: path,
                           components: components,
                           prefixPattern: prefixPattern.appendingPattern(pattern))
    }
    
    internal func match(with pattern: PathPattern) -> PathMatch? {
        
        let pattern = prefixPattern.appendingPattern(pattern)
        
        guard pattern.parts.count == components.count else {
            return nil
        }
        
        var parameters: [String: String] = [:]
        
        for (index, part) in pattern.parts.enumerated() {
            switch part {
            case .string(let string):
                if string != components[index] {
                    return nil
                }
            case .parameter(let name):
                parameters[name] = components[index]
            }
        }
        
        return PathMatch(parameters: parameters)
    }
}
