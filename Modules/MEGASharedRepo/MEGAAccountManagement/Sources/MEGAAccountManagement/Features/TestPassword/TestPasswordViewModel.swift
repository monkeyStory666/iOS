// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAPresentation
import MEGAUIComponent

public final class TestPasswordViewModel: ViewModel<TestPasswordViewModel.Route> {
    public enum Route {
        case forgotPassword(ChangePasswordViewModel)
        case exportRecoveryKey(RecoveryKeyViewModel)
    }

    public enum TestingState {
        case idle
        case testing
        case correct
        case incorrect
    }

    @ViewProperty public var testingState: TestingState = .idle
    @ViewProperty public var password = ""

    var buttonState: MEGAButtonStyle.State {
        switch (password.isEmpty, testingState) {
        case (_, .testing): return .load
        case (false, _): return .default
        case (true, _): return .disabled
        }
    }

    private let testPasswordUseCase: any TestPasswordUseCaseProtocol
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    public init(
        testPasswordUseCase: some TestPasswordUseCaseProtocol,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)? = MEGAAccountManagement.DependencyInjection.analyticsTracker
    ) {
        self.testPasswordUseCase = testPasswordUseCase
        self.analyticsTracker = analyticsTracker
    }

    func onAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .testPasswordScreenView)
        reset()
        observeChanges()
    }

    private func observeChanges() {
        observe {
            $password.sink { [weak self] in self?.passwordDidChange($0) }
        }
    }

    private func passwordDidChange(_ newPassword: String) {
        testingState = .idle
    }

    private func reset() {
        _testingState.updateWithoutAnimation(with: .idle)
        _password.updateWithoutAnimation(with: "")
    }

    func didTestPassword() async {
        testingState = .testing
        if await testPasswordUseCase.testPassword(password) {
            testingState = .correct
        } else {
            testingState = .incorrect
        }
    }

    func didForgotPassword() {
        routeTo(.forgotPassword(ChangePasswordViewModel()))
    }

    func didTapExportRecoveryKeyButton() {
        routeTo(.exportRecoveryKey(DependencyInjection.recoveryKeyViewModel))
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .forgotPassword(let changePasswordViewModel):
            bind(changePasswordViewModel) { [weak self] viewModel in
                viewModel.$route.sink { [weak self] route in
                    switch route {
                    case .dismissed:
                        self?.routeTo(nil)
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
    }
}

extension TestPasswordViewModel.Route {
    var isForgotPassword: Bool {
        if case .forgotPassword = self {
            return true
        } else {
            return false
        }
    }

    var isExportRecoveryKey: Bool {
        switch self {
        case .exportRecoveryKey: true
        default: false
        }
    }
}
