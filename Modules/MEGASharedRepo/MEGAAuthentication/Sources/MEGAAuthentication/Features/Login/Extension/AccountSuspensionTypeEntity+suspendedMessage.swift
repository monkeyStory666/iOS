// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASharedRepoL10n

public extension AccountSuspensionTypeEntity {
    var suspendedMessage: String? {
        switch self {
        case .businessDisabled:
            SharedStrings.Localizable.Login.SuspendedAccountBusinessDisabled.body
        case .businessRemoved:
            SharedStrings.Localizable.Login.SuspendedAccountBusinessRemoved.body
        case .copyright:
            SharedStrings.Localizable.Login.SuspendedAccountCopyright.body
        case .emailVerification:
            SharedStrings.Localizable.Login.SuspendedAccountEmailVerification.body
        case .nonCopyright:
            SharedStrings.Localizable.Login.SuspendedAccountNonCopyright.body
        }
    }
}
