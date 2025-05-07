// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGALogger
import MEGATest

public final class MockLoggingUseCase:
    MockObject<MockLoggingUseCase.Action>,
    LoggingUseCaseProtocol {
    public enum Action: Equatable {
        case logFiles
        case log(
            logLevel: LogLevel,
            message: String,
            filename: String,
            line: Int
        )
        case prepareForLogging
    }

    public var _logFiles: Result<[URL], Error>

    public init(logFiles: Result<[URL], Error> = .success([])) {
        _logFiles = logFiles
    }

    public func logFiles() throws -> [URL] {
        actions.append(.logFiles)
        return try _logFiles.get()
    }

    public func log(
        with logLevel: LogLevel,
        message: String,
        filename: String,
        line: Int
    ) {
        actions.append(
            .log(
                logLevel: logLevel,
                message: message,
                filename: filename,
                line: line
            )
        )
    }

    public func prepareForLogging() {
        actions.append(.prepareForLogging)
    }
}
