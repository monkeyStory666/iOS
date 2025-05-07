// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import Testing

struct RemoteFeatureFlagStateTests {
    @Test func isEnabled() async throws {
        #expect(RemoteFeatureFlagState.disabled.isEnabled == false)
        #expect(RemoteFeatureFlagState.enabled(value: .random()).isEnabled == true)
    }
}
