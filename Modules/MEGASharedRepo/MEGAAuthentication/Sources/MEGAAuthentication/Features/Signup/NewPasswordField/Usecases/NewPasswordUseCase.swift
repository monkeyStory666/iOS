// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol NewPasswordUseCaseProtocol {
    func validate(
        newPassword: String,
        confirmPassword: String
    ) -> NewPasswordValidationEntity
}

public struct NewPasswordUseCase: NewPasswordUseCaseProtocol {
    private let passwordStrengthMeasurer: any PasswordStrengthMeasuring

    public init(passwordStrengthMeasurer: some PasswordStrengthMeasuring) {
        self.passwordStrengthMeasurer = passwordStrengthMeasurer
    }

    public func validate(
        newPassword: String,
        confirmPassword: String
    ) -> NewPasswordValidationEntity {
        NewPasswordValidationEntity(
            newPasswordIssues: NewPasswordIssues(from: newPassword),
            confirmPasswordIssues: ConfirmPasswordIssues(
                newPassword: newPassword,
                confirmPassword: confirmPassword
            ),
            fulfilledRecommendations: PasswordRecommendations(for: newPassword),
            passwordStrength: passwordStrengthMeasurer.passwordStrength(for: newPassword)
        )
    }
}
