// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAConnectivity
import Combine
import Foundation
import Testing
import MEGAConnectivityMocks
import MEGATest

struct NoInternetViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.state == .hidden)
    }

    @Test func onAppear_whenIsNotConnected_shouldUpdateStateToNoInternet() {
        let mockUseCase = MockConnectionUseCase()
        let mockDelayedCaller = MockDelayedCaller()
        let sut = makeSUT(
            connectionUseCase: mockUseCase,
            delayedCaller: mockDelayedCaller.runWithDelay(_:action:)
        )
        sut.onAppear()

        mockUseCase.simulateConnection(isConnected: false)
        mockDelayedCaller.callAllActions(withDelayUpTo: 0)

        #expect(sut.state == .noInternet)
    }

    @Test func onAppear_whenIsConnected_afterNoInternet_shouldUpdateStateToBackOnline_andHideAfterShowtime() {
        let mockUseCase = MockConnectionUseCase()
        let mockDelayedCaller = MockDelayedCaller()
        let sut = makeSUT(
            connectionUseCase: mockUseCase,
            delayedCaller: mockDelayedCaller.runWithDelay(_:action:)
        )
        sut.state = .noInternet

        sut.onAppear()

        mockUseCase.simulateConnection(isConnected: true)
        mockDelayedCaller.callAllActions(withDelayUpTo: NoInternetViewModel.backOnlineShowtime - 0.1)
        #expect(sut.state == .backOnline)

        mockDelayedCaller.callAllActions(withDelayUpTo: NoInternetViewModel.backOnlineShowtime)
        mockDelayedCaller.callAllActions(withDelayUpTo: 0)
        #expect(sut.state == .hidden)
    }

    @Test func onAppear_whenNoInternet_afterBackOnline_shouldNotHideAfterShowtime() {
        let mockUseCase = MockConnectionUseCase()
        let mockDelayedCaller = MockDelayedCaller()
        let sut = makeSUT(
            connectionUseCase: mockUseCase,
            delayedCaller: mockDelayedCaller.runWithDelay(_:action:)
        )
        sut.state = .noInternet

        sut.onAppear()

        mockUseCase.simulateConnection(isConnected: true)
        mockDelayedCaller.callAllActions(withDelayUpTo: NoInternetViewModel.backOnlineShowtime - 0.1)
        #expect(sut.state == .backOnline)

        mockUseCase.simulateConnection(isConnected: false)
        mockDelayedCaller.callAllActions(withDelayUpTo: NoInternetViewModel.backOnlineShowtime)
        #expect(sut.state == .noInternet)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        connectionUseCase: some ConnectionUseCaseProtocol = MockConnectionUseCase(),
        delayedCaller: @escaping DelayedActionCaller = { $0.runWithDelay(_:action:) }(MockDelayedCaller())
    ) -> NoInternetViewModel {
        NoInternetViewModel(
            connectionUseCase: connectionUseCase,
            runOnMainThread: { action in action() },
            delayedCaller: delayedCaller
        )
    }
}

private final class MockDelayedCaller {
    var delayedActions: [(id: UUID, delay: TimeInterval, action: () -> Void)] = []

    func runWithDelay(_ delay: TimeInterval, action: @escaping () -> Void) {
        delayedActions.append((id: UUID(), delay: delay, action: action))
    }

    func callAllActions(withDelayUpTo delay: TimeInterval) {
        for action in delayedActions where action.delay <= delay {
            action.action()
            delayedActions.removeAll(where: { $0.id == action.id })
        }
    }
}
