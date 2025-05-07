// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockPasswordTesting:
    MockObject<MockPasswordTesting.Action>,
    PasswordTesting {
    public enum Action: Equatable {
        case testPassword(password: String)
    }

    public var _testPassword: Bool

    public init(
        testPassword: Bool = true
    ) {
        self._testPassword = testPassword
    }

    public func testPassword(_ password: String) async -> Bool {
        actions.append(.testPassword(password: password))
        return _testPassword
    }
}
