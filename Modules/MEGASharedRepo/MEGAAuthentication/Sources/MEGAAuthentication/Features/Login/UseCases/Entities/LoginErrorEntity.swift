// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum LoginErrorEntity: Error, Equatable, Sendable {
    case generic
    case accountNotValidated
    case badSession
    case twoFactorAuthenticationRequired
    case tooManyAttempts
    case accountSuspended(AccountSuspensionTypeEntity?)
}
