// Copyright © 2023 MEGA Limited. All rights reserved.

import Testing
import MEGASdk
import MEGASDKRepo
import MEGATest

struct ChangeSDKEnvironmentRepositoryTests {
    @Test(
        arguments: [
            SDKEnvironment.production,
            SDKEnvironment.staging
        ]
    ) func setSDKEnvironment_shouldCallChangeAPIUrl_withoutDisablingPKP(
        environment: SDKEnvironment
    ) {
        let mockSdk = MockEnvironmentSdk()
        let sut = makeSUT(sdk: mockSdk)

        sut.setSDKEnvironment(environment)

        #expect(mockSdk.changeApiURLCalls.count == 1)
        #expect(mockSdk.changeApiURLCalls.first?.apiURL == environment.url)
        #expect(mockSdk.changeApiURLCalls.first?.disablepkp == false)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockEnvironmentSdk = MockEnvironmentSdk()
    ) -> ChangeSDKEnvironmentRepository {
        ChangeSDKEnvironmentRepository(sdk: sdk)
    }
}

private final class MockEnvironmentSdk: MEGASdk, @unchecked Sendable  {
    var changeApiURLCalls: [(apiURL: String, disablepkp: Bool)] = []

    override func changeApiUrl(_ apiURL: String, disablepkp: Bool) {
        changeApiURLCalls.append((apiURL, disablepkp))
    }
}
