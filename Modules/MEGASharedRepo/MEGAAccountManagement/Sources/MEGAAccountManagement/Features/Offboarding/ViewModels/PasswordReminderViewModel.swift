// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAPresentation

public final class PasswordReminderViewModel: ViewModel<PasswordReminderViewModel.Route>,
    @unchecked Sendable
{
    public enum Route {
        case presentRecoveryKey(RecoveryKeyViewModel)
        case presentTestPassword(TestPasswordViewModel)
    }

    @ViewProperty var doNotShowThisAgainIsChecked = false

    private var testPasswordSucceeded = false

    private let passwordReminderUseCase: PasswordReminderUseCaseProtocol
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    public init(
        passwordReminderUseCase: PasswordReminderUseCaseProtocol =
            DependencyInjection.passwordReminderUseCase,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)? = DependencyInjection.analyticsTracker
    ) {
        self.passwordReminderUseCase = passwordReminderUseCase
        self.analyticsTracker = analyticsTracker
    }

    func onAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .passwordReminderScreenView)
    }

    func didTapRecoveryKey() {
        clearDontShowThisAgainCheckboxSelection()
        routeTo(.presentRecoveryKey(
            MEGAAccountManagement.DependencyInjection.recoveryKeyViewModel
        ))
    }

    func didTapTestPassword() {
        clearDontShowThisAgainCheckboxSelection()
        routeTo(.presentTestPassword(
            MEGAAccountManagement.DependencyInjection.testPasswordViewModel
        ))
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .presentTestPassword(let testPasswordViewModel):
            bind(testPasswordViewModel) {
                $0.$testingState.sink { [weak self] state in
                    if case .correct = state {
                        self?.testPasswordSucceeded = true
                    }
                }
                $0.$route.sink { [weak self] route in
                    switch route {
                    case .exportRecoveryKey(let viewModel):
                        self?.routeTo(.presentRecoveryKey(viewModel))
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
    }

    public func didProceedToLogout() async {
        if doNotShowThisAgainIsChecked {
            try? await passwordReminderUseCase.passwordReminderBlocked()
        } else if testPasswordSucceeded {
            try? await passwordReminderUseCase.passwordReminderSucceeded()
        } else {
            try? await passwordReminderUseCase.passwordReminderSkipped()
        }
    }

    private func clearDontShowThisAgainCheckboxSelection() {
        if doNotShowThisAgainIsChecked {
            doNotShowThisAgainIsChecked = false
        }
    }
}

extension PasswordReminderViewModel.Route {
    var isPresentingRecoveryKey: Bool {
        if case .presentRecoveryKey = self {
            true
        } else {
            false
        }
    }

    var isPresentingTestPassword: Bool {
        if case .presentTestPassword = self {
            true
        } else {
            false
        }
    }
}
