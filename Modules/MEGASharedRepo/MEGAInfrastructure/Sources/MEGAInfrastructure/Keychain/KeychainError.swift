// Copyright © 2025 MEGA Limited. All rights reserved.

public enum KeychainError: Error, Sendable {
    case generic
    case notFound
    case duplicateItem
    case authenticationFailed
    case interactionNotAllowed
    case invalidParameters
    case missingEntitlement
    case resetFailed
}
