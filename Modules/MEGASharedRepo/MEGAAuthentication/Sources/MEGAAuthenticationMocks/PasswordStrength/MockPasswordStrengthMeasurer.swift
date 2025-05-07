// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockPasswordStrengthMeasurer:
    MockObject<MockPasswordStrengthMeasurer.Action>,
    PasswordStrengthMeasuring {
    public enum Action: Equatable {
        case passwordStrength(String)
    }

    var _passwordStrength: PasswordStrengthEntity

    public init(passwordStrength: PasswordStrengthEntity = .medium) {
        self._passwordStrength = passwordStrength
    }

    public func passwordStrength(for password: String) -> PasswordStrengthEntity {
        actions.append(.passwordStrength(password))

        return _passwordStrength
    }
}
