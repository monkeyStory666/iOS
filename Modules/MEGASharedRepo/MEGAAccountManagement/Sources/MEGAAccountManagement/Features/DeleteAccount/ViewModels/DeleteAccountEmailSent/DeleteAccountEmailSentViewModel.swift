// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAuthentication
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent

public final class DeleteAccountEmailSentViewModel: ViewModel<DeleteAccountEmailSentViewModel.Route> {
    public enum Route {
        case dismissed
    }

    let resendButtonStatePublisher = PassthroughSubject<MEGAButtonStyle.State, Never>()
    private let pin: String?
    private let deleteAccountUseCase: any DeleteAccountUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private var logoutPollingCancellable: Cancellable?

    lazy var emailSentViewModel = MEGAAuthentication.EmailSentViewModel(
        configuration: DeleteAccountEmailSentConfiguration(
            resendButtonStatePublisher: resendButtonStatePublisher, 
            email: deleteAccountUseCase.myEmail() ?? ""
        ),
        analyticsTracker: MEGAAuthentication.DependencyInjection.analyticsTracker,
        supportEmailPresenter: MEGAAuthentication.DependencyInjection.createAccountEmailPresenter
    )

    public init(
        pin: String? = nil,
        deleteAccountUseCase: some DeleteAccountUseCaseProtocol,
        snackbarDisplayer: some SnackbarDisplaying
    ) {
        self.pin = pin
        self.deleteAccountUseCase = deleteAccountUseCase
        self.snackbarDisplayer = snackbarDisplayer
        super.init()
        bindEmailSentViewModel(emailSentViewModel)
    }

    func listenToLogoutEvents() {
        guard logoutPollingCancellable == nil else { return }

        logoutPollingCancellable = deleteAccountUseCase.pollForLogout { [weak self] in
            self?.emailSentViewModel.routeTo(.dismissed)
        }
    }

    func stopListeningToLogoutEvents() {
        logoutPollingCancellable?.cancel()
        logoutPollingCancellable = nil
    }

    // MARK: - Private methods.

    private func retryDeleteAccount() {
        resendButtonStatePublisher.send(.load)

        Task {
            defer { resendButtonStatePublisher.send(.default) }

            do {
                try await deleteAccountUseCase.deleteAccount(with: pin)
                displayResendSuccessfulSnackbar(
                    withMessage: SharedStrings.Localizable.EmailConfirmation.DeleteAccount.ToastMessage.success
                )
            } catch {}
        }
    }

    private func displayResendSuccessfulSnackbar(withMessage message: String) {
        snackbarDisplayer.display(.init(text: message))
    }

    private func bindEmailSentViewModel(_ viewModel: EmailSentViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self, let route else { return }

                switch route {
                case .dismissed:
                    routeTo(.dismissed)
                case .primaryButtonPressed:
                    retryDeleteAccount()
                default:
                    break
                }
            }
        }
    }
}


