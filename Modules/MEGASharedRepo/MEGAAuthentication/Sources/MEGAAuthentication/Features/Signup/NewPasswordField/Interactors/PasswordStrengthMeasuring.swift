// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol PasswordStrengthMeasuring {
    func passwordStrength(for password: String) -> PasswordStrengthEntity
}
