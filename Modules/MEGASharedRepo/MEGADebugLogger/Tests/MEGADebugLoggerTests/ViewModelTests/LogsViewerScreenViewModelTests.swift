// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGADebugLogger
import Foundation
import MEGALogger
import MEGALoggerMocks
import MEGATest
import Testing

struct LogsViewerScreenViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.logWrapper == nil)
    }

    @Test func didTapButton_shouldSetLogWrapper() {
        let expectedURLs = [URL.random, URL.random, URL.random]
        let mockLoggingUseCase = MockLoggingUseCase(logFiles: .success(expectedURLs))
        var stringFromLinkCalls = [URL]()
        let sut = makeSUT(
            loggingUseCase: mockLoggingUseCase,
            stringFromLink: {
                stringFromLinkCalls.append($0)
                return String.random()
            }
        )

        sut.didTapButton()

        #expect(sut.logWrapper?.logs.count == 3)
        #expect(stringFromLinkCalls == expectedURLs)
    }

    @Test func didTapButton_whenLogFilesError_shouldNotSetLogWrapper() {
        let mockLoggingUseCase = MockLoggingUseCase(logFiles: .failure(ErrorInTest()))
        let sut = makeSUT(loggingUseCase: mockLoggingUseCase)

        sut.didTapButton()

        #expect(sut.logWrapper == nil)
    }

    @Test func didTapDismissViewer_shouldSetLogWrapperToNil() {
        let sut = makeSUT()
        sut.logWrapper = LogStringWrapper(logs: [])

        sut.didTapDismissViewer()

        #expect(sut.logWrapper == nil)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        loggingUseCase: some LoggingUseCaseProtocol = MockLoggingUseCase(),
        stringFromLink: @escaping (URL) -> String? = { _ in nil }
    ) -> LogsViewerScreenViewModel {
        LogsViewerScreenViewModel(
            loggingUseCase: loggingUseCase,
            stringFromLink: stringFromLink
        )
    }
}
