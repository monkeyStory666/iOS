// Copyright © 2023 MEGA Limited. All rights reserved.

public enum PasswordStrengthEntity: Int, Comparable {
    case veryWeak = 0
    case weak
    case medium
    case good
    case strong

    public var isValidPassword: Bool {
        self > .veryWeak
    }

    public var isWeakPassword: Bool {
        self < .medium
    }

    public static func < (
        lhs: PasswordStrengthEntity,
        rhs: PasswordStrengthEntity
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
