// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Foundation
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAuthenticationMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGATest
import MEGAUIComponent
import Testing

struct CreateAccountEmailSentViewModelTests {
    @Test func testInitState() {
        let expectedInformation = NewAccountInformationEntity.sample()
        let sut = makeSUT(information: expectedInformation)

        #expect(sut.route == nil)
        #expect(sut.alertToPresent == nil)
        #expect(sut.information == expectedInformation)
        #expect(sut.supportEmail == Constants.Email.support)
    }

    @Test func testOnViewAppear_onLoginFailure_shouldMatch() async {
        await assertOnViewAppear(
            withLoginResult: .failure(NSError(domain: "", code: 0)),
            hasLoggedIn: false,
            assertRoute: { route in #expect(route == nil) }
        )
    }

    @Test func testOnViewAppear_onLoginSuccess_shouldMatch_andTriggerAnalyticsEvent() async {
        let analyticsTracker = MockAnalyticsTracking()

        await assertOnViewAppear(
            withLoginResult: .success(()),
            hasLoggedIn: true,
            assertRoute: { route in #expect(route?.isLoggedIn == true)},
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )

        sleep(1)
        analyticsTracker.swt.assertsEventsEqual(
            to: [
                .emailConfirmationScreenView,
                .accountActivated
            ]
        )
    }

    @Test func testResendConfirmation_onResendFailure_shouldMatch() async {
        await assertResendConfirmation(
            withResendSignUpLinkResult: .failure(NSError(domain: "", code: 0)),
            snackbarDisplayerCalledTimes: 0.times
        )
    }

    @Test func testResendConfirmation_onResendSuccess_shouldMatch() async {
        await assertResendConfirmation(
            withResendSignUpLinkResult: .success(()), snackbarDisplayerCalledTimes: .once
        )
    }

    @Test func testDidCancelRegistration_whenInvoked_shouldMatch() {
        let accountConfirmationUseCase = MockAccountConfirmationUseCase()
        let sut = makeSUT(accountConfirmationUseCase: accountConfirmationUseCase)

        sut.didTapCancelRegistration()

        accountConfirmationUseCase.swt.assert(.cancelCreateAccount, isCalled: .once)
        #expect(sut.route?.isCancelled == true)
    }

    @Test func testDidTapCloseButton_whenInvoked_shouldMatch() {
        let sut = makeSUT()

        sut.didTapCloseButton()

        #expect(
            sut.alertToPresent ==
            .init(
                title: SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.title,
                message: SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.message,
                buttons: [
                    .init(SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.Button.cancelRegistration),
                    .init(
                        SharedStrings.Localizable.EmailConfirmation.CancelRegistrationPopup.Button.cancelPopup,
                        role: .cancel
                    )
                ]
            )
        )
    }

    @Test func testDidTapChangeEmail_shouldRouteToChangeEmail() {
        let sut = makeSUT()

        sut.didTapChangeEmail()

        #expect(sut.route?.isChangeEmail == true)
        #expect(sut.emailSentViewModel.route == nil)
    }

    @Test func testChangeEmailBindings_whenChangeEmailFinished_shouldDismissAndShowSnackbar() {
        let changeEmailViewModel = DependencyInjection.changeEmailViewModel(name: "", email: "")
        let updatedEmail = "newEmail@mega.co.nz"
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(snackbarDisplayer: mockSnackbarDisplayer)
        sut.routeTo(.changeEmail(changeEmailViewModel))

        changeEmailViewModel.routeTo(.finished(updatedEmail))

        #expect(sut.information.email == updatedEmail)
        #expect(sut.route == nil)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: SharedStrings.Localizable.ChangeEmail.successToastMessage))
        ])
    }

    // MARK: - Helpers

    private func makeSUT(
        information: NewAccountInformationEntity = .sample(),
        accountConfirmationUseCase: some AccountConfirmationUseCaseProtocol = MockAccountConfirmationUseCase(),
        loginUseCase: some LoginUseCaseProtocol = MockLoginUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking())
    ) -> CreateAccountEmailSentViewModel {
        CreateAccountEmailSentViewModel(
            information: information,
            accountConfirmationUseCase: accountConfirmationUseCase,
            loginUseCase: loginUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
    }

    private func assertOnViewAppear(
        withLoginResult loginResult: Result<Void, any Error>,
        hasLoggedIn: Bool,
        assertRoute: (CreateAccountEmailSentViewModel.Route?) -> Void,
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking())
    ) async {
        let accountConfirmationUseCase = MockAccountConfirmationUseCase()
        let loginUseCase = MockLoginUseCase(loginResult: loginResult)
        let sut = makeSUT(
            information: .sample(
                email: "test@email.com",
                password: "password"
            ),
            accountConfirmationUseCase: accountConfirmationUseCase,
            loginUseCase: loginUseCase,
            analyticsTracker: analyticsTracker
        )

        await sut.onViewAppear()

        accountConfirmationUseCase.swt.assert(
            .waitForAccountConfirmationEvent, isCalled: .once
        )
        accountConfirmationUseCase.swt.assert(
            .resendSignUpLink(email: "", name: ""), isCalled: 0.times
        )
        loginUseCase.swt.assert(
            .login(username: "test@email.com", password: "password"), isCalled: .once
        )
        assertRoute(sut.route)
    }

    private func assertResendConfirmation(
        withResendSignUpLinkResult resendSignUpLinkResult: Result<Void, any Error>,
        snackbarDisplayerCalledTimes: CallFrequency
    ) async {
        let accountConfirmationUseCase = MockAccountConfirmationUseCase(resendSignUpLinkResult: resendSignUpLinkResult)
        let snackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            information: .sample(
                name: "Name",
                email: "test@email.com"
            ),
            accountConfirmationUseCase: accountConfirmationUseCase,
            snackbarDisplayer: snackbarDisplayer
        )

        await sut.resendConfirmation()

        accountConfirmationUseCase.swt.assert(
            .resendSignUpLink(email: "test@email.com", name: "Name"),
            isCalled: .once
        )
        snackbarDisplayer.swt.assert(
            .display(.init(text: SharedStrings.Localizable.EmailConfirmation.ToastMessage.success)),
            isCalled: snackbarDisplayerCalledTimes
        )
    }
}

extension NewAccountInformationEntity {
    static func sample(
        name: String = "Name",
        email: String = "test@email.com",
        password: String = "Password"
    ) -> Self {
        .init(
            name: name,
            email: email,
            password: password
        )
    }
}
