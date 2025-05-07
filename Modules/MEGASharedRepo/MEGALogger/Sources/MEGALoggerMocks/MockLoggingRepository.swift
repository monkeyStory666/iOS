// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGALogger
import MEGATest

public final class MockLoggingRepository:
    MockObject<MockLoggingRepository.Action>,
    LoggingRepositoryProtocol {
    public enum Action: Equatable {
        case toggleLogging(enabled: Bool)
        case logFiles
        case set(logLevel: LogLevel)
        case setLogToConsole(enabled: Bool)
        case removeLogs
        case logWithLevel(logLevel: LogLevel, message: String, filename: String, line: Int)
    }

    public let logFilesResult: Result<[URL], Error>

    public init(logFilesResult: Result<[URL], Error> = .success([])) {
        self.logFilesResult = logFilesResult
    }

    public func toggleLogging(_ enabled: Bool) {
        actions.append(.toggleLogging(enabled: enabled))
    }

    public func logFiles() throws -> [URL] {
        actions.append(.logFiles)
        return try logFilesResult.get()
    }

    public func set(logLevel: LogLevel) {
        actions.append(.set(logLevel: logLevel))
    }

    public func setLogToConsole(_ enabled: Bool) {
        actions.append(.setLogToConsole(enabled: enabled))
    }

    public func log(
        with logLevel: LogLevel,
        message: String,
        filename: String,
        line: Int
    ) {
        actions.append(
            .logWithLevel(
                logLevel: logLevel,
                message: message,
                filename: filename,
                line: line
            )
        )
    }

    public func removeLogs() throws {
        actions.append(.removeLogs)
    }
}
