// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk

public extension MEGALogLevel {
    func toLogLevel() -> LogLevel {
        switch self {
        case .fatal: return .fatal
        case .error: return .error
        case .warning: return .warning
        case .info: return .info
        case .debug: return .debug
        case .max: return .max
        @unknown default: return .fatal
        }
    }
}

public extension LogLevel {
    func toMEGALogLevel() -> MEGALogLevel {
        switch self {
        case .fatal: return .fatal
        case .error: return .error
        case .warning: return .warning
        case .info: return .info
        case .debug: return .debug
        case .max: return .max
        }
    }
}
