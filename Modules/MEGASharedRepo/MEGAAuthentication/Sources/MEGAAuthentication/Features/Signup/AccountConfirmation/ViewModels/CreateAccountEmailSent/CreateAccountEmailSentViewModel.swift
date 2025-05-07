// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAnalytics
import MEGAInfrastructure
import MEGAUIComponent
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class CreateAccountEmailSentViewModel: ViewModel<CreateAccountEmailSentViewModel.Route> {
    public enum Route {
        case cancelled
        case changeEmail(ChangeEmailViewModel)
        case loggedIn
    }

    private let accountConfirmationUseCase: any AccountConfirmationUseCaseProtocol
    private let loginUseCase: any LoginUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let resendButtonStatePublisher = PassthroughSubject<MEGAButtonStyle.State, Never>()
    private let changeEmailButtonStatePublisher = PassthroughSubject<MEGAButtonStyle.State, Never>()
    private let showLoadingScreenPassthroughSubject = PassthroughSubject<Bool, Never>()
    private let informationUpdatePassthroughSubject = PassthroughSubject<NewAccountInformationEntity, Never>()

    @ViewProperty public var alertToPresent: AlertModel?
    private(set) var information: NewAccountInformationEntity

    var supportEmail: String { Constants.Email.support }

    lazy var emailSentViewModel = DependencyInjection.emailSentViewModel(
        with: CreateAccountEmailSentConfiguration(
            information: information,
            resendButtonStatePublisher: resendButtonStatePublisher,
            changeEmailButtonStatePublisher: changeEmailButtonStatePublisher,
            showLoadingScreenPassthroughSubject: showLoadingScreenPassthroughSubject,
            informationUpdatePassthroughSubject: informationUpdatePassthroughSubject
        )
    )

    public init(
        information: NewAccountInformationEntity,
        accountConfirmationUseCase: some AccountConfirmationUseCaseProtocol,
        loginUseCase: some LoginUseCaseProtocol,
        snackbarDisplayer: some SnackbarDisplaying,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    ) {
        self.information = information
        self.accountConfirmationUseCase = accountConfirmationUseCase
        self.loginUseCase = loginUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.analyticsTracker = analyticsTracker

        super.init()
    }

    public func onViewAppear() async {
        analyticsTracker?.trackAnalyticsEvent(with: .emailConfirmationScreenView)

        bindEmailSentViewModel(emailSentViewModel)
        await accountConfirmationUseCase.waitForAccountConfirmationEvent()
        showLoadingScreenPassthroughSubject.send(true)
        await login()
        showLoadingScreenPassthroughSubject.send(false)
    }

    public func resendConfirmation() async {
        resendButtonStatePublisher.send(.load)
        defer { resendButtonStatePublisher.send(.default) }

        do {
            try await accountConfirmationUseCase.resendSignUpLink(
                withEmail: information.email,
                name: information.name
            )
            displaySuccessfulSnackbar(withMessage: SharedStrings.Localizable.EmailConfirmation.ToastMessage.success)
        } catch {}
    }

    public func didTapCancelRegistration() {
        accountConfirmationUseCase.cancelCreateAccount()
        routeTo(.cancelled)
    }

    public func didTapCloseButton() {
        presentCancelRegistration()
    }

    public func didTapChangeEmail() {
        emailSentViewModel.routeTo(nil)

        routeTo(.changeEmail(
            DependencyInjection.changeEmailViewModel(
                name: information.name,
                email: information.email
            )
        ))
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .changeEmail(let changeEmailViewModel):
            bind(changeEmailViewModel) { [weak self] viewModel in
                viewModel.$route.sink { [weak self] in
                    self?.changeEmailDidRoute(to: $0)
                }
            }
        default:
            break
        }
    }

    // MARK: - Private methods.

    private func login() async {
        do {
            try await loginUseCase.login(with: information.email, and: information.password)
            analyticsTracker?.trackAnalyticsEvent(with: .accountActivated)
            routeTo(.loggedIn)
        } catch {}
    }

    private func presentCancelRegistration() {
        alertToPresent = .init(
            title: SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.title,
            message: SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.message,
            buttons: [
                .init(
                    SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.Button.cancelRegistration,
                    action: { [weak self] in self?.didTapCancelRegistration() }
                ),
                .init(
                    SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.Button.cancelPopup,
                    role: .cancel
                )
            ]
        )
    }

    private func displaySuccessfulSnackbar(withMessage message: String) {
        snackbarDisplayer.display(.init(text: message))
    }

    private func changeEmailDidRoute(to route: ChangeEmailViewModel.Route?) {
        switch route {
        case .finished(let email):
            information.email = email
            displaySuccessfulSnackbar(
                withMessage: SharedStrings.Localizable.ChangeEmail.successToastMessage
            )
            routeTo(nil)
            informationUpdatePassthroughSubject.send(information)
        case .dismiss:
            routeTo(nil)
        default:
            break
        }
    }

    private func bindEmailSentViewModel(_ viewModel: EmailSentViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self, let route else { return }

                switch route {
                case .dismissed:
                    didTapCloseButton()
                case .primaryButtonPressed:
                    Task {
                        await self.resendConfirmation()
                    }
                case .secondaryButtonPressed:
                    didTapChangeEmail()
                }
            }
        }
    }
}

extension CreateAccountEmailSentViewModel.Route {
    var isCancelled: Bool {
        if case .cancelled = self {
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

    var isChangeEmail: Bool {
        if case .changeEmail = self {
            return true
        } else {
            return false
        }
    }
}
