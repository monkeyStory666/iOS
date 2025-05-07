// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGAAccountManagementMocks
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAConnectivity
import MEGAConnectivityMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGATest
import Testing

struct OffboardingViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.route == nil)
    }

    @Test func testDidProceedToLogout_whenNoInternetConnection_shouldDisplayNoInternetSnackbar() async {
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            connectionUseCase: MockConnectionUseCase(
                isConnected: false
            ),
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.didProceedToLogout()

        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(
                text: SharedStrings.Localizable.NoInternetConnection.label
            ))
        ])
    }

    @Test func testDidProceedToLogout_withPreLogoutHandler_shouldBeCalledBeforeLogout() async {
        let mockOffboardingUseCase = MockOffboardingUseCase()
        let sut = makeSUT(offboardingUseCase: mockOffboardingUseCase)

        await confirmation { preLogoutHandlerCalled in
            await sut.didProceedToLogout {
                mockOffboardingUseCase.swt.assertActions(
                    where: {
                        if case .forceLogout = $0 {
                            return true
                        } else {
                            return false
                        }
                    },
                    isCalled: 0.times
                )
                preLogoutHandlerCalled()
            }
        }
    }

    @Test func testDidProceedToLogout_shouldNotCallPreLogoutHandler_ifNoInternetConnection() async {
        let sut = makeSUT(
            connectionUseCase: MockConnectionUseCase(
                isConnected: false
            )
        )

        await confirmation(expectedCount: 0) { preLogoutHandlerCalled in
            await sut.didProceedToLogout {
                preLogoutHandlerCalled()
            }
        }
    }

    @Test func testDidProceedToLogout_shouldTrackLogoutButtonTapped() async {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        await sut.didProceedToLogout()

        mockTracker.swt.assertsEventsEqual(to: [.logoutButtonPressed] )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        connectionUseCase: some ConnectionUseCaseProtocol = MockConnectionUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking(),
        offboardingUseCase: some OffboardingUseCaseProtocol = MockOffboardingUseCase()
    ) -> OffboardingViewModel {
        OffboardingViewModel(
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker),
            offboardingUseCase: offboardingUseCase
        )
    }
}
