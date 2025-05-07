// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGALogger
import Combine
import Foundation
import MEGALoggerMocks
import MEGATest
import Testing

struct LoggingUseCaseTests {
    @Test func logFiles_shouldReturnLogFilesFromRepository() throws {
        let expectedURLs: [URL] = [.random, .random, .random]
        let mockRepository = MockLoggingRepository(logFilesResult: .success(expectedURLs))
        let sut = makeSUT(repository: mockRepository)

        let result = try sut.logFiles()
        #expect(result == expectedURLs)
    }

    @Test func log_shouldLogInRepository() {
        let expectedLogLevel = LogLevel.random
        let expectedMessage = String.random()
        let expectedFileName = String.random()
        let expectedLine = Int.random()

        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(repository: mockRepository)

        sut.log(
            with: expectedLogLevel,
            message: expectedMessage,
            filename: expectedFileName,
            line: expectedLine
        )

        mockRepository.swt.assert(
            .logWithLevel(
                logLevel: expectedLogLevel,
                message: expectedMessage,
                filename: expectedFileName,
                line: expectedLine
            ),
            isCalled: .once
        )
    }

    @Test func prepareForLogging_shouldEnableLogging() {
        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(
            repository: mockRepository,
            isDebugModePublisher: Just(true).eraseToAnyPublisher()
        )

        sut.prepareForLogging()

        mockRepository.swt.assert(
            .toggleLogging(enabled: true),
            isCalled: .once
        )
    }

    @Test func prepareForLogging_multipleTimes_shouldEnableLogging_once() {
        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(
            repository: mockRepository,
            isDebugModePublisher: Just(true).eraseToAnyPublisher()
        )

        sut.prepareForLogging()
        sut.prepareForLogging()
        sut.prepareForLogging()

        mockRepository.swt.assert(
            .toggleLogging(enabled: true),
            isCalled: .once
        )
    }

    @Test func prepareForLogging_shouldNotStartLogging() {
        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(
            repository: mockRepository,
            isDebugModePublisher: Just(false).eraseToAnyPublisher()
        )

        sut.prepareForLogging()

        mockRepository.swt.assert(
            .toggleLogging(enabled: true),
            isCalled: 0.times
        )
    }

    @Test func prepareForLogging_shouldSetLogLevelToMax() {
        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(repository: mockRepository)

        sut.prepareForLogging()

        mockRepository.swt.assert(.set(logLevel: .max), isCalled: .once)
    }

    @Test func prepareForLogging_whenDebugModeToggledOff_andProdConfig_shouldRemoveLogs() {
        let mockRepository = MockLoggingRepository()
        let mockIsDebugModeSubject = PassthroughSubject<Bool, Never>()
        let sut = makeSUT(
            repository: mockRepository,
            isDebugModePublisher: mockIsDebugModeSubject.eraseToAnyPublisher()
        )

        sut.prepareForLogging()
        mockRepository.swt.assert(.removeLogs, isCalled: 0.times)

        mockIsDebugModeSubject.send(false)
        mockRepository.swt.assert(.removeLogs, isCalled: .once)

        mockIsDebugModeSubject.send(true)
        mockRepository.swt.assert(.removeLogs, isCalled: .once)

        mockIsDebugModeSubject.send(false)
        mockRepository.swt.assert(.removeLogs, isCalled: .twice)
    }

    @Test func log_shouldUseXcodeFilenameAndLine() {
        let expectedLogLevel = LogLevel.random
        let expectedMessage = String.random()

        let mockRepository = MockLoggingRepository()
        let sut = makeSUT(repository: mockRepository)

        // This trick is so that we can avoid using static int line values, so that
        // when there is new tests or anything that causes the line to change
        // the unit test is not affected
        let expectedLine = #line; sut.log(
            with: expectedLogLevel,
            message: expectedMessage
        )

        mockRepository.swt.assert(
            .logWithLevel(
                logLevel: expectedLogLevel,
                message: expectedMessage,
                filename: #file,
                line: expectedLine
            ),
            isCalled: .once
        )
    }

    // MARK: - Helpers

    private func makeSUT(
        repository: some LoggingRepositoryProtocol = MockLoggingRepository(),
        isDebugModePublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
    ) -> LoggingUseCase {
        LoggingUseCase(
            repository: repository,
            isDebugModePublisher: isDebugModePublisher
        )
    }
}

extension LogLevel {
    static var random: LogLevel {
        let levels: [LogLevel] = [
            .fatal,
            .error,
            .warning,
            .info,
            .debug,
            .max
        ]

        return levels.randomElement()!
    }
}
