// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift
import MEGAUIComponent

public final class ChangeEmailViewModel: ViewModel<ChangeEmailViewModel.Route> {
    public enum Route: Equatable {
        case dismiss
        case finished(String)
    }

    public enum FieldState: Equatable {
        case normal
        case warning(String)
    }

    @ViewProperty public var name: String
    @ViewProperty public var email: String
    @ViewProperty public var emailFieldState: FieldState = .normal
    @ViewProperty public var buttonState = MEGAButtonStyle.State.default
    @ViewProperty public var alertToPresent: AlertModel?

    private let accountConfirmationUseCase: any AccountConfirmationUseCaseProtocol

    public init(
        name: String,
        email: String,
        accountConfirmationUseCase: some AccountConfirmationUseCaseProtocol
    ) {
        self.name = name
        self.email = email
        self.accountConfirmationUseCase = accountConfirmationUseCase
    }

    func onViewAppear() {
        observeChanges()
    }

    func updateButtonTapped() async {
        updateEmailFieldState()
        guard isEmailValid() else { return }

        buttonState = .load
        defer { buttonState = .default }

        do {
            try await accountConfirmationUseCase.resendSignUpLink(withEmail: email, name: name)
            routeTo(.finished(email))
        } catch ResendSignupLinkError.emailAlreadyInUse {
            presentEmailAlreadyInUse()
        } catch { /* Error handling is not needed for other cases */ }
    }

    func didTapBackButton() {
        routeTo(.dismiss)
    }

    // MARK: - Private methods.

    private func presentEmailAlreadyInUse() {
        alertToPresent = .init(
            title: SharedStrings.Localizable.CreateAccount.ErrorPopup.EmailAlreadyInUse.title,
            message: SharedStrings.Localizable.CreateAccount.ErrorPopup.EmailAlreadyInUse.message,
            buttons: [.init(SharedStrings.Localizable.GeneralAction.actionOK)]
        )
    }

    private func updateEmailFieldState() {
        emailFieldState = isEmailValid() ? .normal : .warning(SharedStrings.Localizable.Login.EnterValidEmailError.message)
    }

    private func isEmailValid() -> Bool {
        !email.isEmpty && email.isValidEmail
    }

    private func observeChanges() {
        observe {
            $email
                .sink { [weak self] _ in
                    guard let self else { return }
                    emailFieldState = .normal
                }
        }
    }
}

extension ChangeEmailViewModel.FieldState {
    var isWarning: Bool {
        if case .warning = self {
            return true
        } else {
            return false
        }
    }
}
