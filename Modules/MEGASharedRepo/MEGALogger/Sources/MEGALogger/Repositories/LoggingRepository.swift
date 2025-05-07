// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

public protocol LoggingRepositoryProtocol {
    func toggleLogging(_ enable: Bool)
    func set(logLevel: LogLevel)
    func setLogToConsole(_ enabled: Bool)
    func log(with logLevel: LogLevel, message: String, filename: String, line: Int)
    func logFiles() throws -> [URL]
    func removeLogs() throws
}

public final class LoggingRepository: LoggingRepositoryProtocol, @unchecked Sendable {
    private let sdk: MEGASdk
    private let sdkType: MEGASdk.Type
    private let diagnosticMessage: (() async -> String)?
    private var loggingTask: Task<Void, Never>?

    public init(
        sdk: MEGASdk,
        diagnosticMessage: (() async -> String)?
    ) {
        self.sdk = sdk
        self.sdkType = type(of: sdk)
        self.diagnosticMessage = diagnosticMessage
    }

    public func toggleLogging(_ enable: Bool) {
        if enable {
            enableLogs()
        } else {
            disableLogs()
        }
    }

    public func set(logLevel: LogLevel) {
        sdkType.setLogLevel(logLevel.toMEGALogLevel())
    }

    public func setLogToConsole(_ enabled: Bool) {
        sdkType.setLogToConsole(enabled)
    }

    public func log(
        with logLevel: LogLevel,
        message: String,
        filename: String = #file,
        line: Int = #line
    ) {
        sdkType.log(
            with: logLevel.toMEGALogLevel(),
            message: "[\(DependencyInjection.clientAppName)] \(message)",
            filename: filename,
            line: line
        )
    }

    public func logFiles() throws -> [URL] {
        try LoggingHelper.shared.logFiles()
    }

    public func removeLogs() throws {
        try LoggingHelper.shared.removeLogsDirectory()
    }

    // MARK: - Helpers

    private func enableLogs() {
        sdk.add(LoggingHelper.shared)

        let logDiagnostics = { [weak self] in
            guard let self, let diagnosticMessage = await diagnosticMessage?() else { return }

            log(with: .info, message: diagnosticMessage)
        }

        Task { await logDiagnostics() }
    }

    private func disableLogs() {
        sdk.remove(LoggingHelper.shared)
    }
}
