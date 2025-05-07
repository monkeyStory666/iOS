// Copyright © 2023 MEGA Limited. All rights reserved.

public struct NewPasswordValidationEntity {
    public var newPasswordIssues: NewPasswordIssues
    public var confirmPasswordIssues: ConfirmPasswordIssues
    public var fulfilledRecommendations: PasswordRecommendations
    public var passwordStrength: PasswordStrengthEntity

    public var isValid: Bool {
        newPasswordIssues.isEmpty
            && confirmPasswordIssues.isEmpty
            && passwordStrength.isValidPassword
    }
}
