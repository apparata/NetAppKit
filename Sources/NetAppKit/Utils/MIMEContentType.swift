//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

/// Known content types as enum, for convenience.
public enum MIMEContentType {
    case text
    case html
    case json
    case xml
    case form
    case multipart(boundary: String)
    case binary
    case other(String)
    
    public var isText: Bool {
        if case .text = self {
            return true
        } else {
            return false
        }
    }
    
    public var isHTML: Bool {
        if case .html = self {
            return true
        } else {
            return false
        }
    }
    
    public var isJSON: Bool {
        if case .json = self {
            return true
        } else {
            return false
        }
    }
    
    public var xml: Bool {
        if case .xml = self {
            return true
        } else {
            return false
        }
    }
    
    public var isForm: Bool {
        if case .form = self {
            return true
        } else {
            return false
        }
    }
    
    public var isMultipart: Bool {
        if case .multipart(_) = self {
            return true
        } else {
            return false
        }
    }
    
    public var isBinary: Bool {
        if case .binary = self {
            return true
        } else {
            return false
        }
    }
    
    public var isOther: Bool {
        if case .other(_) = self {
            return true
        } else {
            return false
        }
    }
    
    public init(mimeType: String?) {
        guard let mimeType = mimeType else {
            self = .other("text/plain")
            return
        }
        
        let components = mimeType.split(separator: ";").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        switch components[0] {
        case "text/plain": self = .text
        case "text/html": self = .html
        case "application/json": self = .json
        case "application/xml": self = .xml
        case "application/x-www-form-urlencoded": self = .form
        case "application/octet-stream": self = .binary
        default:
            if components[0].hasPrefix("multipart/") {
                guard let boundaryString = components.first(where: { $0.hasPrefix("boundary=") }) else {
                    self = .multipart(boundary: "")
                    return
                }
                self = .multipart(boundary: String(boundaryString).chomping(left: "boundary="))
            } else {
                self = .other(mimeType)
            }
        }
    }
    
    public var asString: String {
        switch self {
        case .text: return "text/plain"
        case .html: return "text/html"
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .form: return "application/x-www-form-urlencoded"
        case .binary: return "application/octet-stream"
        case .multipart(let boundary): return "multipart/form-data; boundary=\(boundary)"
        case .other(let mimeType): return mimeType
        }
    }
    
    
}

fileprivate extension String {
    
    /// Example:
    /// ```
    /// "abcdefghijkl".chomping(left: "abcd")
    /// result: "efghijkl"
    /// ```
    func chomping(left prefix: String) -> String {
        if let prefixRange = range(of: prefix) {
            if prefixRange.upperBound >= endIndex {
                return String(self[startIndex..<prefixRange.lowerBound])
            } else {
                return String(self[prefixRange.upperBound..<endIndex])
            }
        }
        return self
    }
}
