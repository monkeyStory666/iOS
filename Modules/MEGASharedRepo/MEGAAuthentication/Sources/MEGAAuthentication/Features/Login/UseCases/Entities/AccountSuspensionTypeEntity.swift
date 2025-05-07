// Copyright © 2024 MEGA Limited. All rights reserved.

public enum AccountSuspensionTypeEntity: Equatable, Sendable {
    case copyright
    case nonCopyright
    case businessDisabled
    case businessRemoved
    case emailVerification
}

public extension AccountSuspensionTypeEntity {
    var isEmailVerification: Bool {
        if case .emailVerification = self {
            return true
        } else {
            return false
        }
    }
}
