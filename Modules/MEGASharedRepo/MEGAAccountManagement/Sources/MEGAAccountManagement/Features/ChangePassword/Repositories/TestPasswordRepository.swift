// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo

public struct TestPasswordRepository: PasswordTesting {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func testPassword(_ password: String) async -> Bool {
        sdk.checkPassword(password)
    }
}
