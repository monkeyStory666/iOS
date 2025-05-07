// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGAAccountManagementMocks
import MEGAAuthentication
import MEGAPresentation
import MEGAPresentationMocks
import MEGATest
import MEGAUIComponent
import MEGASharedRepoL10n
import Testing

struct ChangePasswordViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.buttonState == .default)
    }

    @Test func testDidTapChangePassword_whenPasswordIsInvalid() async {
        await assert(
            whenTapChangePasswordWithPassword: .invalid,
            buttonStateChanges: [],
            snackbarDisplayed: []
        )
    }

    @Test func testDidTapChangePassword_whenRepositorySucceeds() async {
        await assert(
            whenTapChangePasswordWithPassword: .valid(password: "testPassword"),
            withUseCase: MockChangePasswordUseCase(changePassword: .success(())),
            buttonStateChanges: [.load, .default],
            snackbarDisplayed: [.init(
                text: SharedStrings.Localizable.Account.ChangePassword.Snackbar.success
            )]
        ) { sut in
            #expect(sut.route?.isDismissed == true)
        }
    }

    @Test func testDidTapChangePassword_whenRepositoryThrowsError() async {
        await assert(
            whenTapChangePasswordWithPassword: .valid(password: "testPassword"),
            withUseCase: MockChangePasswordUseCase(changePassword: .failure(ErrorInTest())),
            buttonStateChanges: [.load, .default],
            snackbarDisplayed: []
        )
    }

    @Test func testTwoFABindings_whenVerifyingPinSucceed_shouldChangePassword_dismiss_andDisplaySnackbar() async throws {
        let twoFAViewModel = twoFactorAuthViewModel()
        let mockUseCase = MockChangePasswordUseCase(changePassword: .success(()), isTwoFAEnabled: .success(true))
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(useCase: mockUseCase, snackbarDisplayer: mockSnackbarDisplayer)
        await sut.didTapChangePassword(with: .valid(password: "newPassword"))

        await confirmation(in: mockSnackbarDisplayer.actionsPublisher) {
            sut.routeTo(.presentTwoFA(twoFAViewModel))
            twoFAViewModel.routeTo(.verify("123123"))
        }

        mockUseCase.swt.assert(.changePasswordTwoFA("newPassword", "123123"), isCalled: .once)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(
                .init(
                    text: SharedStrings.Localizable.Account.ChangePassword.Snackbar.success
                )
            )
        ])
        #expect(sut.route?.isDismissed == true)
    }

    @Test func testTwoFactorAuthBindings_whenVerifyingPinFails_shouldUpdateTwoFAVM_andDoNotDisplaySnackbar() async throws {
        let twoFAViewModel = twoFactorAuthViewModel()
        let mockUseCase = MockChangePasswordUseCase(changePassword: .success(()), isTwoFAEnabled: .success(true))
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(useCase: mockUseCase, snackbarDisplayer: mockSnackbarDisplayer)
        await sut.didTapChangePassword(with: .valid(password: "newPassword"))

        await confirmation(in: mockSnackbarDisplayer.actionsPublisher) {
            sut.routeTo(.presentTwoFA(twoFAViewModel))
            twoFAViewModel.routeTo(.verify("123123"))
        }

        mockUseCase.swt.assert(.changePasswordTwoFA("newPassword", "123123"), isCalled: .once)
    }

    @Test func testTwoFactorBindings_whenDismissed_shouldRouteToNil() {
        let twoFAViewModel = twoFactorAuthViewModel()
        let sut = makeSUT()
        sut.routeTo(.presentTwoFA(twoFAViewModel))

        twoFAViewModel.routeTo(.dismissed)

        #expect(sut.route == nil)
    }

    @Test func testDidTapChangePassword_givenWhenOldPasswordUsed_shouldReturnError() async {
        await assertDidTapChangePassword(
            isTestPasswordSuccessful: true,
            isTwoFAEnabledCallFrequency: 0.times,
            containsValidationError: true
        )
    }

    @Test func testDidTapChangePassword_givenWhenValidNewPasswordUsed_shouldSucceed() async {
        await assertDidTapChangePassword(
            isTestPasswordSuccessful: false,
            isTwoFAEnabledCallFrequency: .once,
            containsValidationError: false
        )
    }

    @Test func testDidTapDismiss_shouldRouteToDismiss() {
        let sut = makeSUT()

        sut.didTapDismiss()

        #expect(sut.route?.isDismissed == true)
    }

    private func assertDidTapChangePassword(
        isTestPasswordSuccessful: Bool,
        isTwoFAEnabledCallFrequency: CallFrequency,
        containsValidationError: Bool
    ) async {
        let useCase = MockChangePasswordUseCase(isTestPasswordSuccessful: isTestPasswordSuccessful)
        let sut = makeSUT(useCase: useCase)
        let buttonStateChanges = sut.$buttonState.spy()

        await sut.didTapChangePassword(with: .valid(password: "Password"))

        useCase.swt.assert(.testPassword("Password"), isCalled: .once)
        useCase.swt.assert(.isTwoFactorAuthenticationEnabled, isCalled: isTwoFAEnabledCallFrequency)
        #expect((sut.validationError != nil) == containsValidationError)
        #expect(buttonStateChanges.values == [.load, .default])
    }

    // MARK: - Test Helpers

    private typealias SUT = ChangePasswordViewModel

    private func makeSUT(
        useCase: some ChangePasswordUseCaseProtocol = MockChangePasswordUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        ChangePasswordViewModel(
            snackbarDisplayer: snackbarDisplayer, changePasswordUseCase: useCase
        )
    }

    private func twoFactorAuthViewModel() -> TwoFactorAuthenticationViewModel {
        TwoFactorAuthenticationViewModel(
            analyticsTracker: nil
        )
    }

    private func assert(
        whenTapChangePasswordWithPassword passwordValidity: PasswordValidity,
        withUseCase mockUseCase: MockChangePasswordUseCase = MockChangePasswordUseCase(),
        buttonStateChanges expectedButtonStateChanges: [MEGAButtonStyle.State],
        snackbarDisplayed: [SnackbarEntity],
        otherAssertion: (SUT) -> Void = { _ in }
    ) async {
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(useCase: mockUseCase, snackbarDisplayer: mockSnackbarDisplayer)
        let buttonStateChanges = sut.$buttonState.spy()

        await sut.didTapChangePassword(with: passwordValidity)

        #expect(buttonStateChanges.values == expectedButtonStateChanges)
        mockSnackbarDisplayer.swt.assertActions(
            shouldBe: snackbarDisplayed.map {
                MockSnackbarDisplayer.Action.display($0)
            }
        )
        otherAssertion(sut)
    }
}
