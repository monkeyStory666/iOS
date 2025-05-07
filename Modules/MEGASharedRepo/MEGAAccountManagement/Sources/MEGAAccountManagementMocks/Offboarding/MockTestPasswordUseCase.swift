// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockTestPasswordUseCase:
    MockObject<MockTestPasswordUseCase.Action>,
    TestPasswordUseCaseProtocol {
    public enum Action: Equatable {
        case testPassword(String)
    }

    private let _testPassword: Bool

    public init(testPassword: Bool = true) {
        self._testPassword = testPassword
    }

    public func testPassword(_ password: String) async -> Bool {
        actions.append(.testPassword(password))
        return _testPassword
    }
}
