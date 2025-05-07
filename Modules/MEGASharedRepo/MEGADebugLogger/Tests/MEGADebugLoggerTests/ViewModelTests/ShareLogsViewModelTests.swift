// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGADebugLogger
import Foundation
import MEGALogger
import MEGALoggerMocks
import MEGATest
import Testing

struct ShareLogsViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.logsToShare == nil)
    }

    @Test func didTapButton_whenSuccessful_withURLs_shouldUpdateLogsToShare() {
        let expectedURLs: [URL] = [.random, .random, .random]
        let mockUseCase = MockLoggingUseCase(logFiles: .success(expectedURLs))
        let sut = makeSUT(loggingUseCase: mockUseCase)

        sut.onAppear()
        sut.didTapButton()

        #expect(sut.logsToShare?.urls == expectedURLs)
    }

    @Test func didTapButton_whenSuccessful_withEmptyURLs_shouldUpdateLogsToShare() {
        let mockUseCase = MockLoggingUseCase(logFiles: .success([]))
        let sut = makeSUT(loggingUseCase: mockUseCase)

        sut.onAppear()
        sut.didTapButton()

        #expect(sut.logsToShare?.urls.isEmpty == true)
    }

    @Test func didTapButton_whenThrowsError_shouldUpdateLogsToShare() {
        let mockUseCase = MockLoggingUseCase(logFiles: .failure(ErrorInTest()))
        let sut = makeSUT(loggingUseCase: mockUseCase)

        sut.didTapButton()

        #expect(sut.logsToShare?.urls.isEmpty == true)
    }

    // MARK: - Test Helpers

    private func makeSUT(loggingUseCase: some LoggingUseCaseProtocol = MockLoggingUseCase()) -> ShareLogsViewModel {
        ShareLogsViewModel(
            loggingUseCase: loggingUseCase
        )
    }
}
