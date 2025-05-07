// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGALogger
import MEGASdk
import Testing

@Suite(.serialized)
final class LoggingRepositoryTests {
    deinit {
        MockLoggerSdk.cleanClassActions()
    }

    @Test func toggleLogging_whenEnabled_shouldAddLoggingHelperToSdk() {
        let mockSdk = MockLoggerSdk()
        let sut = createSUT(sdk: mockSdk)

        sut.toggleLogging(true)

        #expect(mockSdk.actions.contains(.addLogger))
    }

    @Test func toggleLogging_whenDisabled_shouldRemoveLoggingHelperFromSdk() {
        let mockSdk = MockLoggerSdk()
        let sut = createSUT(sdk: mockSdk)

        sut.toggleLogging(false)

        #expect(mockSdk.actions.contains(.removeLogger))
    }

    @Test func setLogLevel_whenCalled_shouldInvokeSetLogLevelOnSdk() {
        let mockSdk = MockLoggerSdk()
        let sut = createSUT(sdk: mockSdk)

        sut.set(logLevel: .debug)

        #expect(MockLoggerSdk.classActions.contains(.setLogLevel))
    }

    @Test func setLogToConsole_whenCalled_shouldInvokeSetLogToConsoleOnSdk() {
        let mockSdk = MockLoggerSdk()
        let sut = createSUT(sdk: mockSdk)

        sut.setLogToConsole(true)

        #expect(MockLoggerSdk.classActions.contains(.setLogToConsole))
    }

    @Test func log_whenCalled_shouldInvokeLogOnSdk() {
        let mockSdk = MockLoggerSdk()
        let sut = createSUT(sdk: mockSdk)

        sut.log(with: .info, message: "Test message")

        #expect(MockLoggerSdk.classActions.contains(.log))
    }
}

// MARK: - Helper

private extension LoggingRepositoryTests {
    func createSUT(
        sdk: MEGASdk = MockLoggerSdk(),
        diagnosticMessage: (() async -> String)? = nil
    ) -> LoggingRepository {
        LoggingRepository(sdk: sdk, diagnosticMessage: diagnosticMessage)
    }
}

final class MockLoggerSdk: MEGASdk, @unchecked Sendable  {
    var logMessage: String?

    enum Actions {
        case addLogger
        case removeLogger
    }

    enum ClassActions {
        case setLogLevel
        case setLogToConsole
        case log
    }

    private(set) var actions: [Actions] = []
    private(set) nonisolated(unsafe) static var classActions: [ClassActions] = []

    override func add(_ delegate: MEGALoggerDelegate) {
        actions.append(.addLogger)
    }

    override func remove(_ delegate: MEGALoggerDelegate) {
        actions.append(.removeLogger)
    }

    override class func setLogLevel(_ logLevel: MEGALogLevel) {
        classActions.append(.setLogLevel)
    }

    override class func setLogToConsole(_ enabled: Bool) {
        classActions.append(.setLogToConsole)
    }

    override class func log(
        with logLevel: MEGALogLevel,
        message: String,
        filename: String,
        line: Int
    ) {
        classActions.append(.log)
    }

    /// Needs to be called on `tearDown` if you're asserting `ClassActions`
    static func cleanClassActions() {
        classActions = []
    }
}
