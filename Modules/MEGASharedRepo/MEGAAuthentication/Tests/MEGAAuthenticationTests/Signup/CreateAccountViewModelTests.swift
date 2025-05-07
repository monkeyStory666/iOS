// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAConnectivity
import MEGAConnectivityMocks
import MEGAUIComponent
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGASwift
import Testing

struct CreateAccountViewModelTests {
    @Test func testInitState() {
        let sut = makeSUT()

        #expect(sut.firstName.isEmpty)
        #expect(sut.lastName.isEmpty)
        #expect(sut.email.isEmpty)
        #expect(sut.isTermsAndConditionsChecked == false)
        #expect(sut.termsAndConditionsFieldState == .normal)
        #expect(sut.firstNameFieldState == .normal)
        #expect(sut.lastNameFieldState == .normal)
        #expect(sut.emailFieldState == .normal)
        #expect(sut.route == nil)
        #expect(sut.buttonState == .default)
    }

    @Test func testOnAppear_shouldTrackScreenViewAnalyticsEvent() {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )

        sut.onViewAppear()

        analyticsTracker.swt.assertsEventsEqual(to: [.signupScreenView])
    }

    @Test func testDidTapCreateAccount_withInvalidPassword_shouldReturnImmediately() async {
        await assertDidTapCreateAccount(withInvalidState: .password)
    }

    @Test func testDidTapCreateAccount_withInvalidFirstName_shouldReturnImmediately() async {
        await assertDidTapCreateAccount(withInvalidState: .firstName)
    }

    @Test func testDidTapCreateAccount_withInvalidLastName_shouldReturnImmediately() async {
        await assertDidTapCreateAccount(withInvalidState: .lastName)
    }

    @Test func testDidTapCreateAccount_withInvalidEmail_shouldReturnImmediately() async {
        await assertDidTapCreateAccount(withInvalidState: .email)
    }

    @Test func testDidTapCreateAccount_withInvalidTermsOfService_shouldReturnImmediately() async {
        await assertDidTapCreateAccount(withInvalidState: .termsOfService)
    }

    @Test func testDidTapCreateAccount_onSuccess_shouldRouteToEmailConfirmation_withCorrectInformation() async {
        await assertDidTapCreateAccount(
            withCreateAccountResult: .success("Firstname"),
            email: "test@email.com",
            password: "password"
        ) { sut in
            if case .emailConfirmation(let viewModel) = sut.route {
                #expect(
                    viewModel.information ==
                    .sample(
                        name: "Firstname",
                        email: "test@email.com",
                        password: "password"
                    )
                )
            } else {
                Issue.record("Expected to route to Email Confirmation!")
            }
        }
    }

    @Test func testEmailConfirmationViewModelBindings_shouldRouteCorrectly() {
        func assertWhen(
            emailConfRoute: CreateAccountEmailSentViewModel.Route?,
            assertion: (SUT) -> Void
        ) {
            let emailConfViewModel = DependencyInjection.emailConfirmationViewModel(
                with: .sample()
            )
            let sut = makeSUT()
            sut.routeTo(.emailConfirmation(emailConfViewModel))

            emailConfViewModel.routeTo(emailConfRoute)

            assertion(sut)
        }

        assertWhen(emailConfRoute: .cancelled) { sut in
            #expect(sut.route?.isDismissed == true)
        }
    }

    @Test func testEmailConfirmationViewModelBindings_whenLoggedIn_shouldRouteCorrectly() {
        let emailConfViewModel = DependencyInjection.emailConfirmationViewModel(
            with: .sample()
        )
        let sut = makeSUT()
        sut.routeTo(.emailConfirmation(emailConfViewModel))

        emailConfViewModel.routeTo(.loggedIn)

        #expect(sut.route?.isLoggedIn == true)
    }

    @Test func testDidTapCreateAccount_onGenericError_shouldMatch() async {
        await assertDidTapCreateAccount(
            withCreateAccountResult: .failure(SignUpErrorEntity.generic)
        ) { sut in
            #expect(sut.route == nil)
        }
    }

    @Test func testDidTapCreateAccount_withValidInput_butNoInternet_shouldNotCreate_andPresentErrorSnackbar() async {
        let mockCreateAccountUseCase = MockCreateAccountUseCase()
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT_withValidInput(
            createAccountUseCase: mockCreateAccountUseCase,
            connectionUseCase: MockConnectionUseCase(isConnected: false),
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.didTapCreateAccount(with: .valid(password: "validPassword"))

        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(
                text: SharedStrings.Localizable.Onboarding.Snackbar.noNetwork
            ))
        ])
        mockCreateAccountUseCase.swt.assertActions(shouldBe: [])
    }

    @Test func testClearAllFieldStatus_whenInvoked_shouldMatch() {
        let sut = makeSUT()
        sut.firstNameFieldState = .warning("")
        sut.lastNameFieldState = .warning("")
        sut.emailFieldState = .warning("")
        sut.termsAndConditionsFieldState = .warning("")

        sut.clearAllFieldStatus()

        #expect(sut.firstNameFieldState == .normal)
        #expect(sut.lastNameFieldState == .normal)
        #expect(sut.emailFieldState == .normal)
        #expect(sut.termsAndConditionsFieldState == .normal)
    }

    @Test func testDidTapDismiss_shouldRouteToDismiss() {
        let sut = makeSUT()

        sut.didTapDismiss()

        #expect(sut.route?.isDismissed == true)
    }

    @Test func testDidTapLogin_shouldRouteToLogin() {
        let sut = makeSUT()

        sut.didTapLogin()

        #expect(sut.route?.isLogin == true)
    }

    @Test func testDidTapCreateAccount_shouldTrackAnalyticsEvent() async {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker))

        await sut.didTapCreateAccount(with: .valid(password: "validPassword"))

        analyticsTracker.swt.assertsEventsEqual(to: [.createAccountButtonPressed])
    }

    @Test func testDidTapCreateAccount_whenEmailAlreadyInUse_updateEmailFieldState_andPresentAlert() async {
        let sut = makeSUT_withValidInput(createAccountUseCase: MockCreateAccountUseCase(
            createAccountResult: .failure(SignUpErrorEntity.emailAlreadyInUse)
        ))

        await sut.didTapCreateAccount(with: .valid(password: "validPassword"))

        #expect(sut.emailFieldState == .warning(SharedStrings.Localizable.CreateAccount.EmailFieldAlreadyTaken.message))
    }
    
    @Test func nameMaxCharacterLimit_shouldLimitTo40Characters() {
        #expect(makeSUT().nameMaxCharacterLimit == 40)
    }

    // MARK: - Private methods

    private typealias SUT = CreateAccountViewModel

    private func makeSUT(
        createAccountUseCase: some CreateAccountUseCaseProtocol = MockCreateAccountUseCase(),
        connectionUseCase: some ConnectionUseCaseProtocol = MockConnectionUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking())
    ) -> CreateAccountViewModel {
        CreateAccountViewModel(
            createAccountUseCase: createAccountUseCase,
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
    }

    private func makeSUT_withValidInput(
        createAccountUseCase: some CreateAccountUseCaseProtocol = MockCreateAccountUseCase(),
        connectionUseCase: some ConnectionUseCaseProtocol = MockConnectionUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer()
    ) -> CreateAccountViewModel {
        let sut = makeSUT(
            createAccountUseCase: createAccountUseCase,
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer
        )
        sut.firstName = "test Firstname"
        sut.lastName = "test Lastname"
        sut.email = "test@email.com"
        sut.isTermsAndConditionsChecked = true
        return sut
    }

    private enum InvalidState {
        case password
        case firstName
        case lastName
        case email
        case termsOfService
    }

    private func assertDidTapCreateAccount(
        withInvalidState invalidState: InvalidState
    ) async {
        let sut = makeSUT()
        sut.firstName = invalidState == .firstName ? " " : "test Firstname"
        sut.lastName = invalidState == .lastName ? " " : "test Lastname"
        sut.email = invalidState == .email ? " " : "test@email.com"
        sut.isTermsAndConditionsChecked = !(invalidState == .termsOfService)
        let buttonStateSpy = sut.$buttonState.spy()

        let passwordValidity: PasswordValidity = invalidState == .password
        ? .invalid
        : .valid(password: "testPassword")
        await sut.didTapCreateAccount(with: passwordValidity)

        #expect(buttonStateSpy.values.isEmpty)
    }

    private func assertDidTapCreateAccount(
        withCreateAccountResult createAccountResult: Result<String, any Error>,
        firstName: String = "Firstname",
        lastName: String = "Lastname",
        email: String = "test@email.com",
        password: String = "password",
        assertion: (SUT) -> Void
    ) async {
        let createAccountUseCase = MockCreateAccountUseCase(createAccountResult: createAccountResult)
        let sut = makeSUT(createAccountUseCase: createAccountUseCase)
        sut.firstName = firstName
        sut.lastName = lastName
        sut.email = email
        sut.isTermsAndConditionsChecked = true
        let buttonStateSpy = sut.$buttonState.spy()

        await sut.didTapCreateAccount(with: .valid(password: password))

        #expect(
            buttonStateSpy.values ==
            [.load, .default],
            "Button state should load"
        )
        createAccountUseCase.swt.assert(
            .createAccount(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            ),
            isCalled: .once
        )
    }
}
