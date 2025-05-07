// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAConnectivity
import MEGAConnectivityMocks
import MEGASettings
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGATest
import Testing

struct SettingsListLogOutRowViewModelTests {
    @Test func didTapRow_shouldCallActiveLogout() async {
        let mockOffboardingUseCase = MockOffboardingUseCase()
        let sut = SettingsListLogOutRowViewModel(
            offboardingUseCase: mockOffboardingUseCase
        )

        await sut.didTapRow()

        #expect(
            mockOffboardingUseCase.actions ==
            [.activeLogout(OffboardingUseCase.defaultTimeout)]
        )
    }
}
