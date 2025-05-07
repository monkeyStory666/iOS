// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAccountManagementMocks
import Testing

struct PasswordReminderViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.route == nil)
        #expect(sut.doNotShowThisAgainIsChecked == false)
    }

    @Test func testOnAppear_shouldTrackScreenViewEvent() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.onAppear()

        mockTracker.swt.assertsEventsEqual(to: [.passwordReminderScreenView])
    }

    @Test func testDidTapRecoveryKey_shouldPresentRecoveryKeyAndDeselectCheckbox() {
        let sut = makeSUT()

        sut.doNotShowThisAgainIsChecked = true
        sut.didTapRecoveryKey()

        #expect(sut.route?.isPresentingRecoveryKey == true)
        #expect(sut.doNotShowThisAgainIsChecked == false)
    }

    @Test func testDidTapTestPassword_shouldPresentTestPasswordAndDeselectPassword() {
        let sut = makeSUT()

        sut.doNotShowThisAgainIsChecked = true
        sut.didTapTestPassword()

        #expect(sut.route?.isPresentingTestPassword == true)
        #expect(sut.doNotShowThisAgainIsChecked == false)
    }

    @Test func testDidProceedToLogout_whenDoNotShowThisAgainIsChecked_shouldBlockPasswordReminder() async {
        let mockUseCase = MockPasswordReminderUseCase()
        let sut = makeSUT(useCase: mockUseCase)
        sut.doNotShowThisAgainIsChecked = true

        await sut.didProceedToLogout()

        mockUseCase.swt.assert(.passwordReminderBlocked, isCalled: .once)
        mockUseCase.swt.assert(.passwordReminderSucceeded, isCalled: 0.times)
        mockUseCase.swt.assert(.passwordReminderSkipped, isCalled: 0.times)
    }

    @Test func testDidProceedToLogout_whenTestPasswordSucceeded_shouldNoticePasswordReminderSucceed() async {
        let mockUseCase = MockPasswordReminderUseCase()
        let sut = makeSUT(useCase: mockUseCase)
        let testPasswordUseCase = MockTestPasswordUseCase()
        let testPasswordViewModel = TestPasswordViewModel(
            testPasswordUseCase: testPasswordUseCase
        )
        sut.routeTo(.presentTestPassword(testPasswordViewModel))
        testPasswordViewModel.testingState = .correct
        sut.routeTo(nil)

        await sut.didProceedToLogout()

        mockUseCase.swt.assert(.passwordReminderBlocked, isCalled: 0.times)
        mockUseCase.swt.assert(.passwordReminderSucceeded, isCalled: .once)
        mockUseCase.swt.assert(.passwordReminderSkipped, isCalled: 0.times)
    }

    @Test func testDidProceedToLogout_whenNoTestPassword_shouldNoticePasswordReminderSkipped() async {
        let mockUseCase = MockPasswordReminderUseCase()
        let sut = makeSUT(useCase: mockUseCase)

        await sut.didProceedToLogout()

        mockUseCase.swt.assert(.passwordReminderBlocked, isCalled: 0.times)
        mockUseCase.swt.assert(.passwordReminderSucceeded, isCalled: 0.times)
        mockUseCase.swt.assert(.passwordReminderSkipped, isCalled: .once)
    }

    @Test func testTestPasswordBindings_whenTestPasswordRouteToRecoveryKey_shouldPresentRecoveryKey() async {
        let sut = makeSUT()
        let testPasswordViewModel = MEGAAccountManagement.DependencyInjection.testPasswordViewModel
        sut.routeTo(.presentTestPassword(testPasswordViewModel))

        testPasswordViewModel.routeTo(.exportRecoveryKey(
            MEGAAccountManagement.DependencyInjection.recoveryKeyViewModel
        ))

        #expect(sut.route?.isPresentingRecoveryKey == true)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        useCase: some PasswordReminderUseCaseProtocol = MockPasswordReminderUseCase(),
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking()
    ) -> PasswordReminderViewModel {
        PasswordReminderViewModel(
            passwordReminderUseCase: useCase,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )
    }
}
