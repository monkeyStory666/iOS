// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGATest
import Testing

struct RecoveryKeyRepositoryTests {
    @Test(arguments: [
        nil,
        String.random()
    ]) func recoveryKey_shouldFetchFromSDK(expectedMasterKey: String?) {
        let sut = makeSUT(sdk: MockRecoveryKeySdk(
            masterKey: expectedMasterKey
        ))

        #expect(sut.recoveryKey() == expectedMasterKey)
    }

    @Test func keyExported_shouldCallSDK() {
        let mockSdk = MockRecoveryKeySdk()
        let sut = makeSUT(sdk: mockSdk)

        sut.keyExported()

        #expect(mockSdk.masterKeyExportedCallCount == .once)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockRecoveryKeySdk = MockRecoveryKeySdk()
    ) -> RecoveryKeyRepository {
        RecoveryKeyRepository(sdk: sdk)
    }
}

private final class MockRecoveryKeySdk: MEGASdk, @unchecked Sendable {
    var masterKeyExportedCallCount: CallFrequency = 0

    var _masterKey: String?

    init(masterKey: String? = nil) {
        self._masterKey = masterKey
        super.init()
    }

    override var masterKey: String? {
        _masterKey
    }

    override func masterKeyExported() {
        masterKeyExportedCallCount += 1
    }
}
