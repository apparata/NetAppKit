//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import Foundation
#if canImport(os)
import os.log
#endif

// MARK: - Module-wide top-level log functions

/// Logs an arbitrary debug log message.
/// Messages are only logged in debug builds.
///
/// **Example:**
/// ```
/// log("This is a debug message.")
/// ```
internal func log(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    ModuleWideLog.service?.log(message(), file: file, function: function, line: line)
    #endif
}

/// Logs an arbitrary debug log message.
/// Messages are only logged in debug builds when environment variable
/// LOG_VERBOSE is set e.g. in the Xcode Scheme.
///
/// **Example:**
/// ```
/// log(verbose: "This is a debug message.")
/// ```
internal func log(verbose message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    if ProcessInfo.processInfo.environment["LOG_VERBOSE"] != nil {
        ModuleWideLog.service?.log(message(), file: file, function: function, line: line)
    }
    #endif
}

/// Logs an arbitrary public message.
/// Messages are logged in all builds. Do not use for sensitive information.
///
/// **Example:**
/// ```
/// log(public: "This is a public message.")
/// ```
internal func log(public message: String, file: String = #file, function: String = #function, line: Int = #line) {
    ModuleWideLog.service?.log(public: message, file: file, function: function, line: line)
}

/// Logs an error message indicating that something went wrong.
/// Messages are logged in all builds. Do not use for sensitive information.
///
/// **Example:**
/// ```
/// log(error: "This is an error message.")
/// ```
internal func log(error message: String, file: String = #file, function: String = #function, line: Int = #line) {
    ModuleWideLog.service?.log(error: message, file: file, function: function, line: line)
}

/// Logs the localized error description message of an Error object.
/// Messages are logged in all builds. Do not use for sensitive information.
///
/// **Example:**
/// ```
/// log(error: someKindOfError)
/// ```
internal func log(error: Error, file: String = #file, function: String = #function, line: Int = #line) {
    ModuleWideLog.service?.log(error: error.localizedDescription, file: file, function: function, line: line)
}

/// Logs given value's contents using its mirror.
/// Messages are only logged in debug builds.
///
/// **Example:**
/// ```
/// log(dump: MyObject(), name: "MyObject")
/// ```
internal func log<T>(dump value: T, name: String? = nil, indent: Int = 0, maxDepth: Int = Int.max, maxItems: Int = Int.max, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    var message: String = ""
    dump(value, to: &message, name: name, indent: indent, maxDepth: maxDepth, maxItems: maxItems)
    ModuleWideLog.service?.log(message, file: file, function: function, line: line)
    #endif
}

// MARK: - Module-wide log service

public protocol ModuleWideLogService {
    
    /// Logs an arbitrary debug log message.
    /// It will only be called in debug builds.
    func log(_ message: String, file: String, function: String, line: Int)
    
    /// Logs an arbitrary public message.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(public message: String, file: String, function: String, line: Int)
    
    /// Logs an error message indicating that something went wrong.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(error message: String, file: String, function: String, line: Int)
}

public class ModuleWideLog {
    
    /// Module-wide log service.
    #if canImport(os)
    public static var service: ModuleWideLogService? = OSLogService(subsystem: "se.apparata.netlog")
    #else
    public static var service: ModuleWideLogService? = PrintLogService()
    #endif
}

#if canImport(os)

// MARK: - OSLogService

/// OSLog implementation of the ModuleWideLogService protocol.
internal class OSLogService: ModuleWideLogService {
    
    private let osLog: OSLog
    
    public var includeCodeLocation: Bool
    
    /// Initialize the OSLogService for a subsystem.
    ///
    /// - parameter subsystem: A string identifying the subsystem, such as
    ///                        "se.apparata.foundation".
    /// - parameter includeCodeLocation: Includes file, function, and line
    ///                                  information in the log entries.
    init(subsystem: String, includeCodeLocation: Bool = false) {
        osLog = OSLog(subsystem: subsystem, category: "default")
        self.includeCodeLocation = includeCodeLocation
    }
    
    /// Logs an arbitrary debug log message.
    /// It will only be called in debug builds.
    func log(_ message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            os_log("%@", log: osLog, type: .debug, "\(file):\(function):\(line):\(message)")
        } else {
            os_log("%@", log: osLog, type: .debug, message)
        }
    }
    
    /// Logs an arbitrary public message.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(public message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            os_log("%{public}@", log: osLog, type: .info, "\(file):\(function):\(line):\(message)")
        } else {
            os_log("%{public}@", log: osLog, type: .info, message)
        }
    }
    
    /// Logs an error message indicating that something went wrong.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(error message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            os_log("%{public}@", log: osLog, type: .error, "\(file):\(function):\(line):\(message)")
        } else {
            os_log("%{public}@", log: osLog, type: .error, message)
        }
    }
}

#endif

// MARK: - PrintLogService

/// Simple print implementation of the ModuleWideLogService protocol.
internal class PrintLogService: ModuleWideLogService {
    
    public var includeCodeLocation: Bool
    
    /// Initialize the PrintLogService for a subsystem.
    ///
    /// - parameter includeCodeLocation: Includes file, function, and line
    ///                                  information in the log entries.
    init(subsystem: String, includeCodeLocation: Bool = false) {
        self.includeCodeLocation = includeCodeLocation
    }
    
    /// Logs an arbitrary debug log message.
    /// It will only be called in debug builds.
    func log(_ message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            print("\(file):\(function):\(line):\(message)")
        } else {
            print(message)
        }
    }
    
    /// Logs an arbitrary public message.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(public message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            print("\(file):\(function):\(line):\(message)")
        } else {
            print(message)
        }
    }
    
    /// Logs an error message indicating that something went wrong.
    /// It will be called in all builds, and thus should not be
    /// used for sensitive information.
    func log(error message: String, file: String, function: String, line: Int) {
        if includeCodeLocation {
            print("\(file):\(function):\(line):\(message)")
        } else {
            print(message)
        }
    }
}
