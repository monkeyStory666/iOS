// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct LogInformation: Equatable {
    public let time: String
    public let level: LogLevel
    public let source: String
    public let message: String

    public init(time: String, level: LogLevel, source: String, message: String) {
        self.time = time
        self.level = level
        self.source = source
        self.message = message
    }
}
