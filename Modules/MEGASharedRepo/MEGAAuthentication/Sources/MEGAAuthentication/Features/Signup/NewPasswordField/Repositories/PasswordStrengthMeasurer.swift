// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct PasswordStrengthMeasurer: PasswordStrengthMeasuring {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func passwordStrength(for password: String) -> PasswordStrengthEntity {
        sdk.passwordStrength(password).mapToEntity()
    }
}

public extension PasswordStrength {
    func mapToEntity() -> PasswordStrengthEntity {
        switch self {
        case .veryWeak:
            return .veryWeak
        case .weak:
            return .weak
        case .medium:
            return .medium
        case .good:
            return .good
        case .strong:
            return .strong
        @unknown default:
            return .veryWeak
        }
    }
}
