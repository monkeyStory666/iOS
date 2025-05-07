// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent

public final class ChangePasswordViewModel: ViewModel<ChangePasswordViewModel.Route> {
    public enum Route {
        case presentTwoFA(TwoFactorAuthenticationViewModel)
        case dismissed
    }

    @ViewProperty var buttonState: MEGAButtonStyle.State = .default
    @ViewProperty var validationError: String?

    private var newPassword = ""

    private let snackbarDisplayer: any SnackbarDisplaying
    private let changePasswordUseCase: any ChangePasswordUseCaseProtocol

    public init(
        snackbarDisplayer: any SnackbarDisplaying = DependencyInjection.snackbarDisplayer,
        changePasswordUseCase: some ChangePasswordUseCaseProtocol = DependencyInjection.changePasswordUseCase
    ) {
        self.snackbarDisplayer = snackbarDisplayer
        self.changePasswordUseCase = changePasswordUseCase
    }

    func didTapChangePassword(with passwordValidity: PasswordValidity) async {
        guard case .valid(let validPassword) = passwordValidity else { return }

        buttonState = .load
        defer { buttonState = .default }

        guard await changePasswordUseCase.testPassword(validPassword) == false else {
            validationError = SharedStrings.Localizable.Account.NewPassword.oldPasswordUsed
            return
        }

        await checkForTwoFactorAuthenticationAndUpdatePassword(validPassword)
    }

    func didTapDismiss() {
        routeTo(.dismissed)
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .presentTwoFA(let twoFactorAuthenticationViewModel):
            bind(twoFactorAuthenticationViewModel) { [weak self] viewModel in
                viewModel.$route.sink { [weak self] route in
                    switch route {
                    case .verify(let pin):
                        self?.changePassword(
                            with2FAPin: pin,
                            onSuccess: { [weak viewModel] in
                                await viewModel?.didVerifySuccessfully()
                            },
                            onFailure: { [weak viewModel] in
                                await viewModel?.didVerifyWithWrongPasscode()
                            }
                        )
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

    // MARK: - Helpers

    private func checkForTwoFactorAuthenticationAndUpdatePassword(_ newPassword: String) async {
        if (try? await changePasswordUseCase.isTwoFactorAuthenticationEnabled()) == true {
            self.newPassword = newPassword
            routeTo(.presentTwoFA(MEGAAuthentication.DependencyInjection.twoFactorAuthenticationViewModel))
        } else {
            do {
                try await changePasswordUseCase.changePassword(newPassword)
                didChangePasswordSuccessfully()
            } catch {}
        }
    }

    private func changePassword(
        with2FAPin pin: String,
        onSuccess successHandler: @escaping () async -> Void,
        onFailure failureHandler: @escaping () async -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await changePasswordUseCase.changePassword(newPassword, pin: pin)
                await successHandler()
                didChangePasswordSuccessfully()
            } catch {
                await failureHandler()
            }
        }
    }

    private func didChangePasswordSuccessfully() {
        routeTo(.dismissed)
        displaySuccessfulSnackbar()
    }

    private func displaySuccessfulSnackbar() {
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.Account.ChangePassword.Snackbar.success
        ))
    }
}

extension ChangePasswordViewModel.Route {
    var isDismissed: Bool {
        if case .dismissed = self {
            return true
        } else {
            return false
        }
    }
}
