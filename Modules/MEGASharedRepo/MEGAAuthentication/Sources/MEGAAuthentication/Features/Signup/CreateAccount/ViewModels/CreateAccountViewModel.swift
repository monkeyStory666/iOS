// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAConnectivity
import MEGADesignToken
import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift
import MEGAUIComponent
import SwiftUI

public final class CreateAccountViewModel: ViewModel<CreateAccountViewModel.Route> {
    public enum Route {
        case login
        case emailConfirmation(CreateAccountEmailSentViewModel)
        case dismissed
        case loggedIn
    }

    public enum FieldState: Equatable {
        case normal
        case warning(String)
    }

    @ViewProperty public var firstName = ""
    @ViewProperty public var lastName = ""
    @ViewProperty public var email = ""

    @ViewProperty public var isTermsAndConditionsChecked = false
    @ViewProperty public var termsAndConditionsFieldState: FieldState = .normal

    @ViewProperty public var firstNameFieldState: FieldState = .normal
    @ViewProperty public var lastNameFieldState: FieldState = .normal
    @ViewProperty public var emailFieldState: FieldState = .normal

    @ViewProperty public var buttonState = MEGAButtonStyle.State.default

    private let createAccountUseCase: any CreateAccountUseCaseProtocol
    private let connectionUseCase: any ConnectionUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    public let nameMaxCharacterLimit: Int = 40

    public init(
        createAccountUseCase: some CreateAccountUseCaseProtocol,
        connectionUseCase: some ConnectionUseCaseProtocol,
        snackbarDisplayer: some SnackbarDisplaying,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    ) {
        self.createAccountUseCase = createAccountUseCase
        self.connectionUseCase = connectionUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.analyticsTracker = analyticsTracker
    }

    func onViewAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .signupScreenView)
    }

    func didTapCreateAccount(with passwordValidity: PasswordValidity) async {
        analyticsTracker?.trackAnalyticsEvent(with: .createAccountButtonPressed)

        updateFieldStates()
        guard case let .valid(password) = passwordValidity, areAllFieldStatesAreValid() else { return }

        guard isConnectedToNetwork() else {
            presentNoNetworkSnackbar()
            return
        }

        buttonState = .load
        defer { buttonState = .default }

        do {
            let name = try await createAccountUseCase.createAccount(
                withFirstName: firstName, lastName: lastName, email: email, password: password
            )
            routeTo(
                .emailConfirmation(
                    DependencyInjection.emailConfirmationViewModel(
                        with: .init(
                            name: name,
                            email: email,
                            password: password
                        )
                    )
                )
            )
        } catch SignUpErrorEntity.emailAlreadyInUse {
            emailFieldState = .warning(SharedStrings.Localizable.CreateAccount.EmailFieldAlreadyTaken.message)
        } catch { /* Error handling is not needed for other cases */ }
    }

    func didTapDismiss() {
        routeTo(.dismissed)
    }

    func clearAllFieldStatus() {
        firstNameFieldState = .normal
        lastNameFieldState = .normal
        emailFieldState = .normal
        termsAndConditionsFieldState = .normal
    }

    func didTapLogin() {
        routeTo(.login)
    }

    // MARK: - Private methods.

    private func isConnectedToNetwork() -> Bool {
        connectionUseCase.isConnected
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .emailConfirmation(let emailConfirmationViewModel):
            bindEmailConfirmationViewModel(emailConfirmationViewModel)
        default:
            break
        }
    }

    private func bindEmailConfirmationViewModel(_ viewModel: CreateAccountEmailSentViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self else { return }

                switch route {
                case .cancelled:
                    routeTo(.dismissed)
                case .loggedIn:
                    routeTo(.loggedIn)
                default:
                    break
                }
            }
        }
    }

    private func presentNoNetworkSnackbar() {
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.Onboarding.Snackbar.noNetwork
        ))
    }
    
    private var isFirstNameValid: Bool {
        firstName.isNotEmptyOrWhitespace
    }

    private var isLastNameValid: Bool {
        lastName.isNotEmptyOrWhitespace
    }

    private var isEmailValid: Bool {
        email.isNotEmptyOrWhitespace && email.isValidEmail
    }

    private func areAllFieldStatesAreValid() -> Bool {
        isFirstNameValid
        && isLastNameValid
        && isEmailValid
        && isTermsAndConditionsChecked
    }

    private func updateFieldStates() {
        updateFirstNameFieldState()
        updateLastNameFieldState()
        updateEmailFieldState()
        updateTermsAndConditionsFieldState()
    }

    private func updateFirstNameFieldState() {
        firstNameFieldState = isFirstNameValid
        ? .normal
        : .warning(SharedStrings.Localizable.CreateAccount.FirstNameFieldEmpty.message)
    }

    private func updateLastNameFieldState() {
        lastNameFieldState = isLastNameValid
        ? .normal
        : .warning(SharedStrings.Localizable.CreateAccount.LastNameFieldEmpty.message)
    }

    private func updateEmailFieldState() {
        emailFieldState = isEmailValid
        ? .normal
        : .warning(SharedStrings.Localizable.CreateAccount.EmailFieldEmptyOrInvalid.message)
    }

    private func updateTermsAndConditionsFieldState() {
        termsAndConditionsFieldState = isTermsAndConditionsChecked
        ? .normal
        : .warning(SharedStrings.Localizable.CreateAccount.TermsOfServiceUnchecked.message)
    }
}

public extension CreateAccountViewModel.FieldState {
    var isWarning: Bool {
        if case .warning = self {
            return true
        } else {
            return false
        }
    }
}

public extension CreateAccountViewModel.Route {
    var isDismissed: Bool {
        if case .dismissed = self {
            return true
        } else {
            return false
        }
    }

    var isLogin: Bool {
        if case .login = self {
            return true
        } else {
            return false
        }
    }

    var isEmailConfirmation: Bool {
        if case .emailConfirmation = self {
            return true
        } else {
            return false
        }
    }

    var isLoggedIn: Bool {
        if case .loggedIn = self {
            return true
        } else {
            return false
        }
    }
}
