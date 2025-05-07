// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGATest
import Testing

struct NewPasswordUseCaseTests {
    @Test func testValidNewPasswordAndConfirmation() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: "Password1"
        )

        #expect(validation.newPasswordIssues.isEmpty)
        #expect(validation.confirmPasswordIssues.isEmpty)
        #expect(validation.isValid)
    }

    @Test func testInvalidNewPasswordLength() {
        let validation = makeSUT().validate(
            newPassword: "Short1",
            confirmPassword: "Short1"
        )

        #expect(validation.newPasswordIssues.contains(.lessThanMinimumCharacters))
        #expect(validation.isValid == false)
    }

    @Test func testPasswordAndConfirmationMismatch() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: "Password2"
        )

        #expect(validation.confirmPasswordIssues.contains(.doesNotMatch))
    }

    @Test func testEmptyConfirmationPassword() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: ""
        )

        #expect(validation.confirmPasswordIssues.contains(.emptyPassword))
    }

    @Test func testNewPasswordWithoutUppercase() {
        let validation = makeSUT().validate(
            newPassword: "password1",
            confirmPassword: "password1"
        )

        #expect(validation.fulfilledRecommendations.contains(.upperAndLowercaseLetters) == false)
    }

    @Test func testNewPasswordWithoutNumberOrSpecialCharacter() {
        let validation = makeSUT().validate(
            newPassword: "Password",
            confirmPassword: "Password"
        )

        #expect(validation.fulfilledRecommendations.contains(.oneNumberOrSpecialCharacter) == false)
    }

    @Test func testPasswordContainsUppercaseAndLowercase() {
        let validation = makeSUT().validate(
            newPassword: "Password",
            confirmPassword: "Password"
        )

        #expect(validation.fulfilledRecommendations.contains(.upperAndLowercaseLetters))
    }

    @Test func testPasswordContainsNumberOrSpecialCharacter() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: "Password1"
        )

        #expect(validation.fulfilledRecommendations.contains(.oneNumberOrSpecialCharacter))
    }

    @Test func testPasswordsMatch() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: "Password1"
        )

        #expect(validation.confirmPasswordIssues.isEmpty)
    }

    @Test func testPasswordsDoNotMatch() {
        let validation = makeSUT().validate(
            newPassword: "Password1",
            confirmPassword: "Password2"
        )

        #expect(validation.confirmPasswordIssues.contains(.doesNotMatch))
    }

    @Test func testPasswordStrengthVeryWeak() {
        let validation = makeSUT(
            passwordStrengthUseCase: MockPasswordStrengthMeasurer(
                passwordStrength: .veryWeak
            )
        ).validate(
            newPassword: "weak",
            confirmPassword: "weak"
        )

        #expect(validation.passwordStrength == .veryWeak)
        #expect(validation.isValid == false)
    }

    @Test func testPasswordStrengthWeak() {
        let validation = makeSUT(
            passwordStrengthUseCase: MockPasswordStrengthMeasurer(
                passwordStrength: .weak
            )
        ).validate(
            newPassword: "Weak",
            confirmPassword: "Weak"
        )

        #expect(validation.passwordStrength == .weak)
        #expect(validation.isValid == false)
    }

    @Test func testPasswordStrengthMedium() {
        let validation = makeSUT(
            passwordStrengthUseCase: MockPasswordStrengthMeasurer(
                passwordStrength: .medium
            )
        ).validate(
            newPassword: "Password1",
            confirmPassword: "Password1"
        )

        #expect(validation.passwordStrength == .medium)
        #expect(validation.isValid)
    }

    @Test func testPasswordStrengthGood() {
        let validation = makeSUT(
            passwordStrengthUseCase: MockPasswordStrengthMeasurer(
                passwordStrength: .good
            )
        ).validate(
            newPassword: "Password1!",
            confirmPassword: "Password1!"
        )

        #expect(validation.passwordStrength == .good)
        #expect(validation.isValid)
    }

    @Test func testPasswordStrengthStrong() {
        let validation = makeSUT(
            passwordStrengthUseCase: MockPasswordStrengthMeasurer(
                passwordStrength: .strong
            )
        ).validate(
            newPassword: "StrongPassword1!",
            confirmPassword: "StrongPassword1!"
        )

        #expect(validation.passwordStrength == .strong)
        #expect(validation.isValid)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        passwordStrengthUseCase: some PasswordStrengthMeasuring = MockPasswordStrengthMeasurer()
    ) -> some NewPasswordUseCaseProtocol {
        NewPasswordUseCase(passwordStrengthMeasurer: passwordStrengthUseCase)
    }
}
