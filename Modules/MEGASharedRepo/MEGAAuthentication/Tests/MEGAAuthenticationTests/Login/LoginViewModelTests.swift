// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Combine
import MEGAAuthenticationMocks
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAConnectivity
import MEGAConnectivityMocks
import MEGAInfrastructure
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGASwift
import MEGATest
import MEGAUIComponent
import Testing

struct LoginViewModelTests {
    private var subscriptions = Set<AnyCancellable>()

    @Test func testInitialState() async {
        let sut = makeSUT(username: "test@test.com", password: "password")
        let username = sut.username
        let password = sut.password
        let shouldSecurePassword = sut.shouldSecurePassword

        #expect(username == "test@test.com")
        #expect(password == "password")
        #expect(shouldSecurePassword)
        #expect(sut.route == nil)
    }

    @Test func testOnAppear_shouldTrackScreenViewAnalyticsEvent() {
        let tracker = MockAnalyticsTracking()
        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: tracker)
        )

        sut.onAppear()

        tracker.swt.assertsEventsEqual(to: [.loginScreenView])
    }

    @Test func testUsernameFieldState_onUsernameEmpty_shouldReturnWarning() async {
        let sut = makeSUT()
        await sut.didTapLogin()
        await assertUserFieldState(with: sut, expectedValue: .warning(SharedStrings.Localizable.Login.EnterValidEmailError.message))
    }

    @Test func testUsernameFieldState_onUsernameInvalidEmail_shouldReturnWarning() async {
        let sut = makeSUT(username: "test")
        await sut.didTapLogin()
        await assertUserFieldState(with: sut, expectedValue: .warning(SharedStrings.Localizable.Login.EnterValidEmailError.message))
    }

    @Test func testUsernameFieldState_onValidFormatUsername_shouldReturnNormal() async {
        let sut = makeSUT(username: "test@test.com")
        await sut.didTapLogin()
        await assertUserFieldState(with: sut, expectedValue: .normal)
    }

    @Test func testUsernameChanged_afterErrorLogin_shouldReturnBothInputFromWarningNormal() async {
        let sut = makeSUT()
        sut.onAppear()
        sut.username = "test"
        await sut.didTapLogin()

        sut.username = "validEmail@gmail.com"

        await assertUserFieldState(with: sut, expectedValue: .normal)
        await assertPasswordFieldState(with: sut, expectedValue: .normal)
    }

    @Test func testPasswordFieldState_onPasswordEmpty_shouldReturnWarning() async {
        let sut = makeSUT()
        await sut.didTapLogin()
        await assertPasswordFieldState(with: sut, expectedValue: .warning(SharedStrings.Localizable.Login.EnterPasswordError.message))
    }

    @Test func testPasswordFieldState_onNonEmptyPassword_shouldReturnNormal() async {
        let sut = makeSUT(password: "testPassword")
        await sut.didTapLogin()
        await assertPasswordFieldState(with: sut, expectedValue: .normal)
    }

    @Test func testPasswordChanged_afterErrorLogin_shouldReturnBothInputFromWarningNormal() async {
        let sut = makeSUT()
        sut.onAppear()
        sut.username = "test"
        await sut.didTapLogin()

        sut.password = "validKey123"

        await assertUserFieldState(with: sut, expectedValue: .normal)
        await assertPasswordFieldState(with: sut, expectedValue: .normal)
    }

    @Test func testButtonState_verifyButtonInitialState_shouldReturnDefault() async {
        let sut = makeSUT()
        let buttonState = sut.buttonState
        #expect(buttonState == .default)
    }

    @Test func testButtonState_whenUserTapsOnLoginWithValidCredentials_shouldTransitionStates() async {
        let sut = makeSUT(username: "test@test.com", password: "testPassword")
        await assertButtonStatesWhenLoginTapped(for: sut, expectedStates: [.load, .default])
    }

    @Test func testButtonState_whenUserTapsOnLoginWithEmptyCrdentials_shouldNoChangeStates() async {
        let sut = makeSUT()
        await assertButtonStatesWhenLoginTapped(for: sut, expectedStates: [])
    }

    @Test func testDidTapLogin_onLoginGenericFailure_shouldNotRouteToLoggedIn_shouldShowInvalidCredentials() async {
        let error = LoginErrorEntity.generic
        let loginUseCase = MockLoginUseCase(loginResult: .failure(error))
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase
        )

        await sut.didTapLogin()

        #expect(sut.route == nil)
        #expect(sut.errorBannerSubtitle == SharedStrings.Localizable.Login.InvalidDetailsError.title)
        #expect(sut.usernameFieldState == .warning(""))
        #expect(sut.passwordFieldState == .warning(""))
    }

    @Test func testDidTapLogin_onTwoFARequiredError_shouldShowTwoFA() async {
        let error = LoginErrorEntity.twoFactorAuthenticationRequired
        let loginUseCase = MockLoginUseCase(loginResult: .failure(error))
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase
        )

        await sut.didTapLogin()

        #expect(sut.route?.isTwoFA == true)
    }

    @Test func testDidTapLogin_onAccountNotValidated_shouldPresentSnackbar() async {
        let error = LoginErrorEntity.accountNotValidated
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let loginUseCase = MockLoginUseCase(loginResult: .failure(error))
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase,
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.didTapLogin()

        #expect(sut.route == nil)
        #expect(
            mockSnackbarDisplayer.actions == [
                .display(.init(
                    text: SharedStrings.Localizable.Login.Snackbar.accountNotValidated
                ))
            ]
        )
    }

    @Test func testDidTapLogin_onLoginTooManyAttemptsFailure_shouldNotRouteToLoggedIn_shouldLockedOutError() async {
        let error = LoginErrorEntity.tooManyAttempts
        let loginUseCase = MockLoginUseCase(loginResult: .failure(error))
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase
        )

        await sut.didTapLogin()

        loginUseCase.swt.assert(
            .login(
                username: "test@test.com",
                password: "test"
            ),
            isCalled: .once
        )
        #expect(sut.route == nil)
        #expect(sut.errorBannerSubtitle == SharedStrings.Localizable.Login.TooManyLoginAttempts.message)
        #expect(sut.usernameFieldState == .warning(""))
        #expect(sut.passwordFieldState == .warning(""))
    }

    @Test func testDidTapLogin_whenSuspended_andTypeNil_shouldPresentInvalidEmailOrPassword() async {
        let error = LoginErrorEntity.accountSuspended(nil)
        let loginUseCase = MockLoginUseCase(
            loginResult: .failure(error)
        )
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase
        )

        await sut.didTapLogin()

        #expect(sut.route == nil)
        #expect(sut.errorBannerSubtitle == SharedStrings.Localizable.Login.InvalidDetailsError.title)
        #expect(sut.usernameFieldState == .warning(""))
        #expect(sut.passwordFieldState == .warning(""))
    }

    @Test func testDidTapLogin_onSuspended_shouldNotRouteToLoggedIn_shouldShowSuspendedAlert() async throws {
        let suspensionType = AccountSuspensionTypeEntity.copyright
        let loginUseCase = MockLoginUseCase(
            loginResult: .failure(LoginErrorEntity.accountSuspended(suspensionType))
        )
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase
        )

        await sut.didTapLogin()

        #expect(sut.route == nil)
        #expect(
            sut.alertToPresent == AlertModel(
                title: SharedStrings.Localizable.Login.SuspendedAccount.title,
                message: suspensionType.suspendedMessage ?? "",
                buttons: [
                    .init(
                        SharedStrings.Localizable.Login.SuspendedAccount.Alert.Button.title,
                        role: .cancel
                    )
                ]
            )
        )

        let dismissButton = try #require(sut.alertToPresent?.buttons.first)
        dismissButton.action()

        #expect(sut.username == "")
        #expect(sut.password == "")
        #expect(sut.alertToPresent == nil)
    }

    @Test func testDidTapLogin_onSuspended_shouldNotRouteToLoggedIn_shouldShowEmailVerificationAlert() async throws {
        let suspension = AccountSuspensionTypeEntity.emailVerification
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let loginUseCase = MockLoginUseCase(
            loginResult: .failure(LoginErrorEntity.accountSuspended(suspension))
        )
        let sut = makeSUT(
            username: "test@test.com",
            password: "test",
            loginUseCase: loginUseCase,
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.didTapLogin()

        #expect(sut.route == nil)
        #expect(
            sut.alertToPresent == AlertModel(
                title: SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.title,
                message: suspension.suspendedMessage ?? "",
                buttons: [
                    .init(
                        SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.Button.title,
                        role: .cancel
                    ),
                    .init(SharedStrings.Localizable.Login.SuspendedAccount.Alert.Button.title)
                ]
            )
        )

        let resendEmailButton = try #require(sut.alertToPresent?.buttons.first)
        resendEmailButton.action()

        loginUseCase.swt.assert(.resendVerificationEmail, isCalled: .once)
        #expect(sut.username == "")
        #expect(sut.password == "")
        #expect(sut.alertToPresent == nil)
        #expect(mockSnackbarDisplayer.actions == [.display(.init(
            text: SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.snackbar
        ))])
    }

    @Test func testDidTapLogin_onLoginSuccess_shouldRouteToLoggedIn_andNotShowAlert() async {
        let loginUseCase = MockLoginUseCase()
        let sut = makeSUT(username: "test@test.com", password: "test", loginUseCase: loginUseCase)

        await sut.didTapLogin()

        loginUseCase.swt.assert(
            .login(username: "test@test.com", password: "test"),
            isCalled: .once
        )
        #expect(sut.route?.isLoggedIn == true)
        #expect(sut.errorBannerSubtitle == nil)
        #expect(sut.alertToPresent == nil)
    }

    @Test func testDidTapDismiss_shouldRouteToDismiss() {
        let sut = makeSUT()

        sut.didTapDismiss()

        #expect(sut.route?.isDismissed == true)
    }

    @Test func testDidTapSignUp_shouldTrackAnalyticsEvent_andRouteToSignUp() {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )

        sut.didTapSignUp()

        analyticsTracker.swt.assertsEventsEqual(to: [.signupButtonOnLoginPagePressed])
        #expect(sut.route?.isSignUp == true)
    }

    @Test func testTwoFactorAuthBindings_whenVerifyingPinSucceeds_shouldLoginWithPin_andRouteToLoggedIn() async {
        let twoFAViewModel = twoFactorAuthViewModel()
        let mockLoginUseCase = MockLoginUseCase(loginResult: .success(()))
        let sut = makeSUT(loginUseCase: mockLoginUseCase)
        sut.username = "username"
        sut.password = "password"
        sut.routeTo(.twoFactorAuthentication(twoFAViewModel))

        await confirmation(in: sut.$route.filter { $0?.isLoggedIn == true }) {
            twoFAViewModel.routeTo(.verify("123123"))
        }

        mockLoginUseCase.swt.assertActions(shouldBe: [
            .twoFactorLogin(
                username: "username",
                password: "password",
                pin: "123123"
            )
        ])
    }

    @Test func testTwoFactorAuthBindings_whenVerifyingPinFails_shouldUpdateTwoFAVM_andRouteStaysInTwoFA() async {
        let twoFAViewModel = twoFactorAuthViewModel()
        let mockLoginUseCase = MockLoginUseCase(loginResult: .failure(ErrorInTest()))
        let sut = makeSUT(loginUseCase: mockLoginUseCase)
        sut.username = "username"
        sut.password = "password"
        sut.routeTo(.twoFactorAuthentication(twoFAViewModel))

        await confirmation(in: mockLoginUseCase.actionsPublisher) {
            twoFAViewModel.routeTo(.verify("123123"))
        }

        mockLoginUseCase.swt.assertActions(shouldBe: [
            .twoFactorLogin(
                username: "username",
                password: "password",
                pin: "123123"
            )
        ])
        #expect(sut.route?.isTwoFA == true)
    }

    @Test func testTwoFactorAuthBindings_whenFailsWithBlockedError_shouldRouteToNil_andPresentAlert() async {
        let twoFAViewModel = twoFactorAuthViewModel()
        let mockLoginUseCase = MockLoginUseCase(
            loginResult: .failure(LoginErrorEntity.accountSuspended(.copyright))
        )
        let sut = makeSUT(loginUseCase: mockLoginUseCase)
        sut.username = "username"
        sut.password = "password"
        sut.routeTo(.twoFactorAuthentication(twoFAViewModel))

        await confirmation(
            in: Publishers.CombineLatest(
                sut.$alertToPresent,
                sut.$route.filter { $0 == nil }
            )
        ) {
            twoFAViewModel.routeTo(.verify("1234"))
        }

        #expect(sut.alertToPresent != nil)
    }

    @Test func testDidTapLogin_withValidFormat_butNoInternetConnection_shouldNotLogin_andPresentErrorSnackbar() async {
        let mockLoginUseCase = MockLoginUseCase()
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            username: "test@test.com", password: "testPassword",
            loginUseCase: mockLoginUseCase,
            connectionUseCase: MockConnectionUseCase(isConnected: false),
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.didTapLogin()

        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(
                text: SharedStrings.Localizable.Onboarding.Snackbar.noNetwork
            ))
        ])
        mockLoginUseCase.swt.assertActions(shouldBe: [])
    }

    @Test func testDidTapLogin_shouldTrackLoginButtonPressed() async {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(
                tracker: mockTracker
            )
        )

        await sut.didTapLogin()

        mockTracker.swt.assertsEventsEqual(to: [.loginButtonPressed])
    }

    @Test func testTwoFactorBindings_whenDismissed_shouldRouteToNil() {
        let twoFAViewModel = twoFactorAuthViewModel()
        let sut = makeSUT()
        sut.routeTo(.twoFactorAuthentication(twoFAViewModel))

        twoFAViewModel.routeTo(.dismissed)

        #expect(sut.route == nil)
    }

    @Test func loginViewModel_route_isLoggedIn() {
        #expect(LoginViewModel.Route.loggedIn.isLoggedIn)
        #expect(LoginViewModel.Route.twoFactorAuthentication(twoFactorAuthViewModel()).isLoggedIn == false)
        #expect(LoginViewModel.Route.dismissed.isLoggedIn == false)
        #expect(LoginViewModel.Route.signUp.isLoggedIn == false)
    }

    @Test func loginViewModel_route_isTwoFA() {
        #expect(LoginViewModel.Route.twoFactorAuthentication(twoFactorAuthViewModel()).isTwoFA)
        #expect(LoginViewModel.Route.loggedIn.isTwoFA == false)
        #expect(LoginViewModel.Route.dismissed.isTwoFA == false)
        #expect(LoginViewModel.Route.signUp.isTwoFA == false)
    }

    @Test func loginViewModel_route_isDismissed() {
        #expect(LoginViewModel.Route.dismissed.isDismissed)
        #expect(LoginViewModel.Route.loggedIn.isDismissed == false)
        #expect(LoginViewModel.Route.twoFactorAuthentication(twoFactorAuthViewModel()).isDismissed == false)
        #expect(LoginViewModel.Route.signUp.isDismissed == false)
    }

    @Test func loginViewModel_route_isSignUp() {
        #expect(LoginViewModel.Route.signUp.isSignUp)
        #expect(LoginViewModel.Route.loggedIn.isSignUp == false)
        #expect(LoginViewModel.Route.twoFactorAuthentication(twoFactorAuthViewModel()).isSignUp == false)
        #expect(LoginViewModel.Route.dismissed.isSignUp == false)
    }

    @Test func testShouldShowSignUpButton_whenSceneTypeIsNormal_shouldReturnTrue() {
        let sut = makeSUT(sceneType: .normal)
        #expect(sut.shouldShowSignUpButton == true)
    }

    @Test(
        arguments: [SceneTypeEntity.autofill, .importPassword]
    ) func testShouldShowSignUpButton_whenSceneTypeIsNotNormal_shouldReturnFalse(sceneType: SceneTypeEntity) {
        let sut = makeSUT(sceneType: sceneType)
        #expect(sut.shouldShowSignUpButton == false)
    }

    // MARK: - Test Helpers

    private typealias SUT = LoginViewModel

    private func makeSUT(
        username: String = "",
        password: String = "",
        sceneType: SceneTypeEntity = .normal,
        loginUseCase: some LoginUseCaseProtocol = MockLoginUseCase(),
        connectionUseCase: some ConnectionUseCaseProtocol = MockConnectionUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking())
    ) -> SUT {
        let sut = SUT(
            sceneType: sceneType,
            loginUseCase: loginUseCase,
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
        sut.username = username
        sut.password = password
        return sut
    }

    private func twoFactorAuthViewModel() -> TwoFactorAuthenticationViewModel {
        TwoFactorAuthenticationViewModel(
            analyticsTracker: nil
        )
    }

    private func assertUserFieldState(
        with sut: SUT,
        expectedValue: FieldState
    ) async {
        let usernameFieldState = sut.usernameFieldState
        #expect(usernameFieldState == expectedValue)
    }

    private func assertPasswordFieldState(
        with sut: SUT,
        expectedValue: FieldState
    ) async {
        let passwordFieldState = sut.passwordFieldState
        #expect(passwordFieldState == expectedValue)
    }

    private func assertButtonStatesWhenLoginTapped(
        for sut: SUT,
        expectedStates: [MEGAButtonStyle.State]
    ) async {
        let buttonStates = sut.$buttonState.spy()
        await sut.didTapLogin()
        #expect(buttonStates.values == expectedStates)
    }
}
