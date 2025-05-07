// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Foundation
import MEGAAuthenticationMocks
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import MEGATest
import Testing

struct ChangeEmailViewModelTests {
    @Test func testInitState() {
        let sut = makeSUT(name: "Name", email: "test@email.com")
        #expect(sut.name == "Name")
        #expect(sut.email == "test@email.com")
        #expect(sut.emailFieldState == .normal)
        #expect(sut.buttonState == .default)
    }

    @Test func testOnViewAppear_whenInvoked_shouldMatch() async {
        let sut = makeSUT()
        sut.buttonState = .load

        sut.onViewAppear()

        let result = await confirmation(
            in: sut.$emailFieldState.filter { $0 == .normal }
        ) {
            sut.email = "email@gmail.com"
        }

        #expect(result == [.normal])
    }

    @Test func testUpdateButtonTapped_withEmailFieldStateInvalid_shouldReturnImmediately() async {
        let sut = makeSUT(email: "")
        let buttonStateSpy = sut.$buttonState.spy()

        await sut.updateButtonTapped()
        #expect(buttonStateSpy.values.isEmpty)
    }

    @Test func testUpdateButtonTapped_onFailure_shouldMatch() async {
        await assertUpdateButtonTapped(
            withResendSignUpLinkResult: .failure(NSError(domain: "", code: 0)),
            expectedEmail: "",
            assertRoute: { route in #expect(route == nil) }
        )
    }

    @Test func testUpdateButtonTapped_whenAlreadyRegisteredEmailIsUsed_shouldMatch() async {
        await assertUpdateButtonTapped(
            withResendSignUpLinkResult: .failure(ResendSignupLinkError.emailAlreadyInUse),
            expectedEmail: "",
            expectedAlert: .init(
                title: SharedStrings.Localizable.CreateAccount.ErrorPopup.EmailAlreadyInUse.title,
                message: SharedStrings.Localizable.CreateAccount.ErrorPopup.EmailAlreadyInUse.message,
                buttons: [.init(SharedStrings.Localizable.GeneralAction.actionOK)]
            ),
            assertRoute: { route in #expect(route == nil) }
        )
    }

    @Test func testUpdateButtonTapped_onSuccess_shouldMatch() async {
        await assertUpdateButtonTapped(
            withResendSignUpLinkResult: .success(()),
            expectedEmail: "test@email.com",
            assertRoute: { route in #expect(route == .finished("test@email.com"))}
        )
    }

    @Test func didTapBackButton_shouldSetRouteToDismiss() {
        let sut = makeSUT()

        sut.didTapBackButton()

        #expect(sut.route == .dismiss)
    }

    // MARK: - Private methods.
    private func makeSUT(
        name: String = "Name",
        email: String = "test@email.com",
        accountConfirmationUseCase: some AccountConfirmationUseCaseProtocol = MockAccountConfirmationUseCase()
    ) -> ChangeEmailViewModel {
        ChangeEmailViewModel(
            name: name,
            email: email,
            accountConfirmationUseCase: accountConfirmationUseCase
        )
    }

    private func assertUpdateButtonTapped(
        withResendSignUpLinkResult resendSignUpLinkResult: Result<Void, any Error>,
        expectedEmail: String,
        expectedAlert: AlertModel? = nil,
        assertRoute: (ChangeEmailViewModel.Route?) -> Void
    ) async {
        let accountConfirmationUseCase = MockAccountConfirmationUseCase(
            resendSignUpLinkResult: resendSignUpLinkResult
        )
        let sut = makeSUT(
            name: "Name",
            email: "test@email.com",
            accountConfirmationUseCase: accountConfirmationUseCase
        )
        let buttonStateSpy = sut.$buttonState.spy()

        await sut.updateButtonTapped()

        #expect(buttonStateSpy.values == [.load, .default])
        accountConfirmationUseCase.swt.assert(
            .resendSignUpLink(email: "test@email.com", name: "Name"),
            isCalled: .once
        )
        assertRoute(sut.route)
        #expect(sut.alertToPresent == expectedAlert)
    }
}
