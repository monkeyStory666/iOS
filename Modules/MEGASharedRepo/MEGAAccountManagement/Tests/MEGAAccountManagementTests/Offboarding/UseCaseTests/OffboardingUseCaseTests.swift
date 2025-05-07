// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGAConnectivity
import MEGAConnectivityMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGATest
import Testing

final class OffboardingUseCaseTests {
    private var mockLoginAPIRepository = MockLoginAPIRepository()
    private var mockLoginStoreRepository = MockLoginStoreRepository()
    private var mockAppLoadingManager = MockAppLoadingStateManager()
    private var mockPasswordReminderUseCase = MockPasswordReminderUseCase()
    private var mockAnalyticsTracker = MockAnalyticsTracking()
    private var mockConnectionUseCase = MockConnectionUseCase()
    private var mockSnackbarDisplayer = MockSnackbarDisplayer()

    private var preLogoutActionCalls = 0
    private var postLogoutActionCalls = 0

    private var sut: OffboardingUseCase!

    @Test func activeLogout_shouldTrackLogoutButtonPressed() async {
        let sut = makeSUT()

        await sut.activeLogout()

        mockAnalyticsTracker.swt.assertsEventsEqual(to: [.logoutButtonPressed])
    }

    @Test func activeLogout_withNoInternetConnection_shouldNotTrackAnalytics() async {
        mockConnectionUseCase.simulateConnection(isConnected: false)
        let sut = makeSUT()

        await sut.activeLogout()

        mockAnalyticsTracker.swt.assertsEventsEmpty()
    }

    @Test func activeLogout_whenNotShowPasswordReminder_shouldNotStartOffboarding_andLogoutImmediately() async {
        mockPasswordReminderUseCase._shouldShowPasswordReminder = false
        let sut = makeSUT()
        let startOffboarding = sut.startOffboardingPublisher().spy()

        await sut.activeLogout()

        assertLogoutCalled()
        #expect(startOffboarding.values.isEmpty)
    }

    @Test func activeLogout_withNoInternetConnection_shouldNotLogoutImmediately() async {
        mockConnectionUseCase.simulateConnection(isConnected: false)
        mockPasswordReminderUseCase._shouldShowPasswordReminder = false
        let sut = makeSUT()

        await sut.activeLogout()

        assertLogoutNotCalled()
    }

    @Test func activeLogout_whenShowPasswordReminder_shouldStartOffboarding_andNotLogoutImmediately() async {
        mockPasswordReminderUseCase._shouldShowPasswordReminder = true
        let sut = makeSUT()
        let startOffboarding = sut.startOffboardingPublisher().spy()

        await sut.activeLogout()

        assertLogoutNotCalled()
        #expect(startOffboarding.values.count == 1)
    }

    @Test func activeLogout_withNoInternetConnection_shouldNotStartOffboarding() async {
        mockConnectionUseCase.simulateConnection(isConnected: false)
        let sut = makeSUT()
        let startOffboarding = sut.startOffboardingPublisher().spy()

        await sut.activeLogout()

        #expect(startOffboarding.values.isEmpty)
    }

    @Test func forceLogout_shouldLogoutImmediately() async {
        let sut = makeSUT()

        await sut.forceLogout()

        assertLogoutCalled()
    }

    // MARK: - Test Helpers

    private func assertLogoutCalled(line: UInt = #line) {
        #expect(
            mockAppLoadingManager.actions == [
                .startLoading(.init(blur: true, allowUserInteraction: false)),
                .stopLoading
            ]
        )
        #expect(mockLoginStoreRepository.actions == [.delete])
        #expect(mockLoginAPIRepository.actions == [.logout, .set(accountAuth: nil)])
        #expect(preLogoutActionCalls == 1)
        #expect(postLogoutActionCalls == 1)
    }

    private func assertLogoutNotCalled() {
        #expect(mockLoginStoreRepository.actions.isEmpty)
        #expect(mockLoginAPIRepository.actions.isEmpty)
        #expect(preLogoutActionCalls == 0)
        #expect(postLogoutActionCalls == 0)
    }

    private func makeSUT() -> OffboardingUseCase {
        OffboardingUseCase(
            loginAPIRepository: mockLoginAPIRepository,
            loginStoreRepository: mockLoginStoreRepository,
            appLoadingManager: mockAppLoadingManager,
            passwordReminderUseCase: mockPasswordReminderUseCase,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: mockAnalyticsTracker),
            connectionUseCase: mockConnectionUseCase,
            snackbarDisplayer: mockSnackbarDisplayer,
            preLogoutAction: { [weak self] in self?.preLogoutActionCalls += 1},
            postLogoutAction: { [weak self] in self?.postLogoutActionCalls += 1}
        )
    }
}
