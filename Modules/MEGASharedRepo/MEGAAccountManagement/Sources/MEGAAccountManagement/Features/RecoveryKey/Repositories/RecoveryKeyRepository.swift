// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct RecoveryKeyRepository: RecoveryKeyRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func recoveryKey() -> String? {
        sdk.masterKey
    }

    public func keyExported() {
        sdk.masterKeyExported()
    }
}

