// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import SwiftUI

typealias DelayedActionCaller = (TimeInterval, @escaping () -> Void) -> Void
typealias RunOnMainThread = (@escaping () -> Void) -> Void

public final class NoInternetViewModel: ObservableObject {
    static var backOnlineShowtime: TimeInterval = 3

    public enum State {
        case hidden
        case noInternet
        case backOnline
    }

    @Published public var state: State = .hidden

    private var cancellable: AnyCancellable?
    private let connectionUseCase: any ConnectionUseCaseProtocol
    private let delayedCaller: DelayedActionCaller
    private let runOnMainThread: RunOnMainThread

    init(
        connectionUseCase: some ConnectionUseCaseProtocol,
        runOnMainThread: @escaping RunOnMainThread,
        delayedCaller: @escaping DelayedActionCaller
    ) {
        self.connectionUseCase = connectionUseCase
        self.runOnMainThread = runOnMainThread
        self.delayedCaller = delayedCaller
        updateState(when: connectionUseCase.isConnected)
    }

    func onAppear() {
        cancellable = connectionUseCase.isConnectedPublisher.sink { [weak self] isConnected in
            self?.updateState(when: isConnected)
        }
    }

    private func updateState(when isConnected: Bool) {
        switch (isConnected, state) {
        case (false, .hidden), (false, .backOnline):
            updateState(to: .noInternet)
        case (true, .noInternet):
            updateStateToBackOnline()
        case (true, .hidden), (true, .backOnline), (false, .noInternet):
            break
        }
    }

    private func updateStateToBackOnline() {
        updateState(to: .backOnline)
        hideAfterDelay()
    }

    private func hideAfterDelay() {
        delayedCaller(Self.backOnlineShowtime) { [weak self] in
            guard let self, state == .backOnline else { return }

            updateState(to: .hidden)
        }
    }

    private func updateState(to state: State) {
        delayedCaller(0) { [weak self] in
            self?.runOnMainThread {
                withAnimation {
                    self?.state = state
                }
            }
        }
    }
}
