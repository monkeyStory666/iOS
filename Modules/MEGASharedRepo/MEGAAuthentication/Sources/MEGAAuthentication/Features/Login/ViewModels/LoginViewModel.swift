// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAAnalytics
import MEGAConnectivity
import MEGADesignToken
import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift
import MEGAUIComponent

public final class LoginViewModel: ViewModel<LoginViewModel.Route>, LoginContentViewModelProtocol {
    public enum Route {
        case twoFactorAuthentication(TwoFactorAuthenticationViewModel)
        case signUp
        case loggedIn
        case dismissed
    }

    public enum PresentedError: Equatable {
        case none
        case invalidCredentials
        case lockedOut
    }

    // Needs to use @Published because AutoFill don't work correctly using ViewProperty
    @Published public var username: String = ""
    @ViewProperty public var password: String = ""
    @ViewProperty public var shouldSecurePassword = true
    @ViewProperty public var usernameFieldState: FieldState = .normal
    @ViewProperty public var passwordFieldState: FieldState = .normal
    @ViewProperty public var buttonState: MEGAButtonStyle.State = .default
    @ViewProperty public var errorBannerSubtitle: String?
    @ViewProperty public var alertToPresent: AlertModel?

    private let sceneType: SceneTypeEntity
    private let loginUseCase: any LoginUseCaseProtocol
    private let connectionUseCase: any ConnectionUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    private var isUserCredentialsInValidFormat: Bool {
        guard !username.isEmpty,
              username.isValidEmail,
              !password.isEmpty else { return false }

        return true
    }

    public init(
        sceneType: SceneTypeEntity,
        loginUseCase: some LoginUseCaseProtocol,
        connectionUseCase: some ConnectionUseCaseProtocol,
        snackbarDisplayer: some SnackbarDisplaying,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    ) {
        self.sceneType = sceneType
        self.loginUseCase = loginUseCase
        self.connectionUseCase = connectionUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.analyticsTracker = analyticsTracker
    }

    public func onAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .loginScreenView)

        let usernameField = $username.removeDuplicates()
        let passwordField = $password.removeDuplicates()

        observe {
            usernameField.merge(with: passwordField)
                .sink { [weak self] _ in
                    guard let self else { return }
                    usernameFieldState = .normal
                    passwordFieldState = .normal
                    errorBannerSubtitle = nil
                }
        }
    }

    public func didTapLogin() async {
        analyticsTracker?.trackAnalyticsEvent(with: .loginButtonPressed)

        guard isUserCredentialsInValidFormat else {
            updateUsernameFieldState()
            updatePasswordFieldState()
            return
        }

        guard isConnectedToNetwork() else {
            presentNoNetworkSnackbar()
            return
        }

        buttonState = .load
        defer { buttonState = .default }

        do {
            try await loginUseCase.login(with: username, and: password)
            routeTo(.loggedIn)
        } catch LoginErrorEntity.twoFactorAuthenticationRequired {
            showTwoFAScreen()
        } catch LoginErrorEntity.accountNotValidated {
            presentAccountNotValidatedSnackBar()
        } catch LoginErrorEntity.tooManyAttempts {
            presentLockedOutError()
        } catch LoginErrorEntity.accountSuspended(let suspensionType) {
            presentSuspendedAccountError(suspensionType: suspensionType)
        } catch {
            presentInvalidEmailOrPasswordError()
        }
    }

    public func didTapDismiss() {
        routeTo(.dismissed)
    }

    public func didTapSignUp() {
        analyticsTracker?.trackAnalyticsEvent(with: .signupButtonOnLoginPagePressed)

        routeTo(.signUp)
    }

    public var shouldShowSignUpButton: Bool {
        sceneType.isNormal
    }

    override public func bindNewRoute(_ route: Route?) {
        switch route {
        case let .twoFactorAuthentication(twoFactorAuthViewModel):
            bindTwoFactorAuthViewModel(twoFactorAuthViewModel)
        default:
            break
        }
    }

    // MARK: - Private methods.

    private func isConnectedToNetwork() -> Bool {
        connectionUseCase.isConnected
    }

    private func bindTwoFactorAuthViewModel(_ viewModel: TwoFactorAuthenticationViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self else { return }

                switch route {
                case let .verify(pin):
                    login(
                        with2FAPin: pin,
                        onSuccess: { [weak viewModel] in
                            await viewModel?.didVerifySuccessfully()
                        },
                        onFailure: { [weak self, weak viewModel] error in
                            guard let self, let viewModel else { return }
                            await handle2FAError(
                                error: error,
                                viewModel: viewModel
                            )
                        }
                    )
                case .dismissed:
                    routeTo(nil)
                default:
                    break
                }
            }
        }
    }

    private func handle2FAError(
        error: LoginErrorEntity,
        viewModel: TwoFactorAuthenticationViewModel
    ) async {
        switch error {
        case .accountSuspended(let suspensionType):
            // Gets routed back to login from the 2FA screen
            routeTo(nil)
            presentSuspendedAccountError(suspensionType: suspensionType)
        default:
            await viewModel.didVerifyWithWrongPasscode()
        }
    }

    private func presentAccountNotValidatedSnackBar() {
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.Login.Snackbar.accountNotValidated
        ))
    }

    private func presentNoNetworkSnackbar() {
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.Onboarding.Snackbar.noNetwork
        ))
    }

    private func login(
        with2FAPin pin: String,
        onSuccess successHandler: @escaping () async -> Void,
        onFailure failureHandler: @escaping (LoginErrorEntity) async -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await loginUseCase.login(
                    with: username,
                    and: password,
                    pin: pin
                )
                await successHandler()
                routeTo(.loggedIn)
            } catch let error as LoginErrorEntity {
                await failureHandler(error)
            }
        }
    }

    private func updateUsernameFieldState() {
        usernameFieldState = (username.isEmpty || !username.isValidEmail)
        ? .warning(SharedStrings.Localizable.Login.EnterValidEmailError.message)
        : .normal
    }

    private func updatePasswordFieldState() {
        passwordFieldState = password.isEmpty
        ? .warning(SharedStrings.Localizable.Login.EnterPasswordError.message)
        : .normal
    }

    private func presentInvalidEmailOrPasswordError() {
        errorBannerSubtitle = SharedStrings.Localizable.Login.InvalidDetailsError.title
        setFieldsToWarning()
    }

    private func presentLockedOutError() {
        errorBannerSubtitle = SharedStrings.Localizable.Login.TooManyLoginAttempts.message
        setFieldsToWarning()
    }

    private func presentSuspendedAccountError(suspensionType: AccountSuspensionTypeEntity?) {
        guard let suspensionType, let message = suspensionType.suspendedMessage else {
            // Shouldn't happen, as this indicates that the account is not blocked
            // but if it somehow does, present the generic error message
            presentInvalidEmailOrPasswordError()
            return
        }

        let dismissButton: AlertButtonModel = .init(
            SharedStrings.Localizable.Login.SuspendedAccount.Alert.Button.title,
            role: suspensionType.isEmailVerification ? nil : .cancel,
            action: { [weak self] in
                guard let self else { return }

                clearCredentials()
                alertToPresent = nil
            }
        )

        if suspensionType.isEmailVerification {
            alertToPresent = suspendedAccountEmailVerificationAlertModel(
                message: message,
                dismissButton: dismissButton
            )
        } else {
            alertToPresent = .init(
                title: SharedStrings.Localizable.Login.SuspendedAccount.title,
                message: message,
                buttons: [dismissButton]
            )
        }
    }

    private func suspendedAccountEmailVerificationAlertModel(
        message: String,
        dismissButton: AlertButtonModel
    ) -> AlertModel {
        let resendEmailButton: AlertButtonModel = .init(
            SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.Button.title,
            role: .cancel,
            action: { [weak self] in
                guard let self else { return }

                clearCredentials()
                loginUseCase.resendVerificationEmail()
                snackbarDisplayer.display(.init(
                    text: SharedStrings.Localizable.Login
                        .SuspendedAccountEmailVerification.snackbar
                ))
                alertToPresent = nil
            }
        )

        return .init(
            title: SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.title,
            message: message,
            buttons: [resendEmailButton, dismissButton]
        )
    }

    private func clearCredentials() {
        mainDispatchQueue.async { [weak self] in
            self?.username = ""
            self?.password = ""
        }
    }

    private func setFieldsToWarning() {
        usernameFieldState = .warning("")
        passwordFieldState = .warning("")
    }

    private func showTwoFAScreen() {
        routeTo(.twoFactorAuthentication(DependencyInjection.twoFactorAuthenticationViewModel))
    }
}

public extension LoginViewModel.Route {
    var isLoggedIn: Bool {
        if case .loggedIn = self {
            true
        } else {
            false
        }
    }

    var isTwoFA: Bool {
        if case .twoFactorAuthentication = self {
            true
        } else {
            false
        }
    }

    var isDismissed: Bool {
        if case .dismissed = self {
            true
        } else {
            false
        }
    }

    var isSignUp: Bool {
        if case .signUp = self {
            true
        } else {
            false
        }
    }
}
