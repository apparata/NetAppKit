//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public enum JSONValue {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])
    
    /// Defaults to `.object([:])`
    public init() {
        self = .object([:])
    }

    public subscript(dynamicMember member: String) -> Int? {
        get {
            if case .object(let object) = self {
                if case .int(let value) = object[member] {
                    return value
                }
            }
            return nil
        }
        set {
            if let value = newValue {
                self[dynamicMember: member] = .int(value)
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> Double? {
        get {
            if case .object(let object) = self {
                if case .double(let value) = object[member] {
                    return value
                }
            }
            return nil
        }
        set {
            if let value = newValue {
                self[dynamicMember: member] = .double(value)
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> Bool? {
        get {
            if case .object(let object) = self {
                if case .bool(let value) = object[member] {
                    return value
                }
            }
            return nil
        }
        set {
            if let value = newValue {
                self[dynamicMember: member] = .bool(value)
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> String? {
        get {
            if case .object(let object) = self {
                if case .string(let string) = object[member] {
                    return string
                }
            }
            return nil
        }
        set {
            if let string = newValue {
                self[dynamicMember: member] = .string(string)
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> JSONValue? {
        get {
            if case .object(let object) = self {
                return object[member]
            }
            return nil
        }
        set {
            if case .object(let object) = self {
                var modifiedObject = object
                modifiedObject[member] = newValue
                self = .object(modifiedObject)
            }
        }
    }
}

extension JSONValue: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .int(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .double(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .bool(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .string(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .array(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .object(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }
}
