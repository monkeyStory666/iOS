// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGATest
import MEGAUIComponent
import Testing

struct TestPasswordViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.testingState == .idle)
        #expect(sut.password.isEmpty)
    }

    @Test func testButtonState_whenIsTesting_shouldBeLoading() {
        assertButtonState(
            shouldBe: .load,
            when: { sut in
                sut.password = ""
                sut.testingState = .testing
            }
        )

        assertButtonState(
            shouldBe: .load,
            when: { sut in
                sut.password = .random()
                sut.testingState = .testing
            }
        )
    }

    @Test func testButtonState_whenPasswordIsNotEmpty_shouldBeDefault() {
        assertButtonState(
            shouldBe: .default,
            when: { sut in
                sut.password = .random(withPrefix: "validPassword")
                sut.testingState = .idle
            }
        )
    }

    @Test func testButtonState_whenPasswordIsEmpty_shouldBeDisabled() {
        assertButtonState(
            shouldBe: .disabled,
            when: { sut in
                sut.password = ""
                sut.testingState = .idle
            }
        )
    }

    @Test func testDidTapPassword_shouldUpdateTestingState() async {
        func assert(
            whenPasswordIsCorrect isCorrect: Bool,
            testingStatesShouldBe expectedStates: [SUT.TestingState],
            line: UInt = #line
        ) async {
            let mockUseCase = MockTestPasswordUseCase(testPassword: isCorrect)
            let sut = makeSUT(testPasswordUseCase: mockUseCase)
            let testingStateSpy = sut.$testingState.spy()

            await sut.didTestPassword()

            #expect(testingStateSpy.values == expectedStates)
        }

        await assert(
            whenPasswordIsCorrect: true,
            testingStatesShouldBe: [.testing, .correct]
        )

        await assert(
            whenPasswordIsCorrect: false,
            testingStatesShouldBe: [.testing, .incorrect]
        )
    }

    @Test func testDidTapExportRecoveryKeyButton_shouldRouteToExportRecoveryKey() {
        let sut = makeSUT()

        sut.didTapExportRecoveryKeyButton()

        #expect(sut.route?.isExportRecoveryKey == true)
    }

    @Test func testOnAppear_shouldResetState() {
        let sut = makeSUT()
        sut.password = "anyPassword"
        sut.testingState = .correct

        sut.onAppear()

        #expect(sut.password.isEmpty)
        #expect(sut.testingState == .idle)
    }

    @Test func testOnAppear_shouldTrackScreenViewEvent() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.onAppear()

        mockTracker.swt.assertsEventsEqual(to: [.testPasswordScreenView])
    }

    @Test func testOnAppear_whenPasswordDidChange_shouldObservePasswordChanges_andResetTestingState() {
        let sut = makeSUT()
        sut.onAppear()
        sut.password = "firstPassword"
        sut.testingState = .correct

        sut.password = "secondPassword"

        #expect(sut.testingState == .idle)
    }

    @Test func testDidTapForgotPassword_shouldRouteToForgotPassword() {
        let sut = makeSUT()

        sut.didForgotPassword()

        #expect(sut.route?.isForgotPassword == true)
    }

    @Test func testForgotPasswordBindings_shouldDismissWhenChangePasswordFinished() {
        let changePasswordViewModel = ChangePasswordViewModel()
        let sut = makeSUT()
        sut.routeTo(.forgotPassword(changePasswordViewModel))

        changePasswordViewModel.routeTo(.dismissed)

        #expect(sut.route == nil)
    }

    // MARK: - Test Helpers

    private typealias SUT = TestPasswordViewModel
    private func makeSUT(
        testPasswordUseCase: some MockTestPasswordUseCase = MockTestPasswordUseCase(),
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking(),
        file: StaticString = #file, line: UInt = #line
    ) -> SUT {
        TestPasswordViewModel(
            testPasswordUseCase: testPasswordUseCase,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )
    }

    private func assertButtonState(
        shouldBe expectedButtonState: MEGAButtonStyle.State,
        when action: (SUT) -> Void
    ) {
        let sut = makeSUT()

        action(sut)

        #expect(sut.buttonState == expectedButtonState)
    }
}

// MARK: - Mocks

final class MockTestPasswordUseCase:
    MockObject<MockTestPasswordUseCase.Action>,
    TestPasswordUseCaseProtocol {
    enum Action: Equatable {
        case testPassword(String)
    }

    var _testPassword: Bool

    init(testPassword: Bool = true) {
        self._testPassword = testPassword
    }

    func testPassword(_ password: String) async -> Bool {
        actions.append(.testPassword(password))
        return _testPassword
    }
}
