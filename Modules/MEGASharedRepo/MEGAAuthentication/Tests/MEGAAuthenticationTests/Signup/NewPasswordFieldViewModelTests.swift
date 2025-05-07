// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Combine
import MEGATest
import MEGAUIComponent
import MEGASharedRepoL10n
import Testing

struct NewPasswordFieldViewModelTests {
    private var bag: Set<AnyCancellable> = .init()

    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.newPassword == "")
        #expect(sut.hideNewPassword)
        #expect(sut.showNewPasswordInformation == false)
        #expect(sut.newPasswordCustomBorderColor == nil)
        #expect(
            sut.newPasswordValidationLabel ==
            .information(NewPasswordFieldViewModel.newPasswordMinimumCharacterText)
        )

        #expect(sut.confirmPassword == "")
        #expect(sut.hideConfirmPassword)
        #expect(sut.confirmPasswordCustomBorderColor == nil)
        #expect(sut.confirmPasswordValidationLabel == nil)
        #expect(sut.validation == nil)
    }

    @Test func testOnAppear_shouldStartObservingChanges() {
        let mockUseCase = MockNewPasswordUseCase()
        let sut = makeSUT(newPasswordUseCase: mockUseCase)

        sut.onAppear()
        mockUseCase.swt.assertActions(shouldBe: [.validate(newPassword: "", confirmPassword: "")])

        sut.newPassword = "anyPassword"
        mockUseCase.swt.assertActions(shouldBe: [
            .validate(newPassword: "", confirmPassword: ""),
            .validate(newPassword: "anyPassword", confirmPassword: "")
        ])

        sut.confirmPassword = "confirmPassword"
        mockUseCase.swt.assertActions(shouldBe: [
            .validate(newPassword: "", confirmPassword: ""),
            .validate(newPassword: "anyPassword", confirmPassword: ""),
            .validate(newPassword: "anyPassword", confirmPassword: "confirmPassword")
        ])
    }

    @Test func testBorderColorShouldBeUpdated_onValidationWhenNewPasswordIsExist_andResetOnChange() {
        let mockUseCase = MockNewPasswordUseCase(
            validation: .sample(
                newPasswordIssues: .lessThanMinimumCharacters,
                confirmPasswordIssues: .doesNotMatch
            )
        )
        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        _ = sut.passwordValidity()
        sut.newPassword = "changed"

        #expect(sut.newPasswordCustomBorderColor == nil)
        #expect(sut.confirmPasswordCustomBorderColor == nil)
    }

    @Test func testBorderColorShouldBeUpdated_onValidationWhenPasswordStrengthIsWeak() {
        let mockUseCase = MockNewPasswordUseCase(
            validation: .sample(
                newPasswordIssues: [],
                passwordStrength: .veryWeak
            )
        )
        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        _ = sut.passwordValidity()

        #expect(sut.newPasswordCustomBorderColor != nil)
    }

    @Test func testNewPasswordBorderColorShouldBeUpdated_onInvalidPassword() {
        let mockUseCase = MockNewPasswordUseCase(
            validation: .sample(passwordStrength: .veryWeak)
        )

        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        sut.newPassword = "sssssssss"
        #expect(sut.newPasswordCustomBorderColor != nil)
    }

    @Test func testNewPasswordBorderColorShouldNotBeUpdated_whenConfirmPasswordChanges() async {
        let mockUseCase = MockNewPasswordUseCase(
            validation: .sample(passwordStrength: .veryWeak)
        )

        let sut = makeSUT(newPasswordUseCase: mockUseCase)

        sut.newPassword = "sssssssss"
        sut.confirmPassword = "s"

        await confirmation(
            in: sut.$newPasswordCustomBorderColor.compactMap { $0 },
            "New password border color should not be updated"
        ) {
            sut.onAppear()
        }
    }

    // swiftlint:disable:next function_body_length
    @Test func testNewPasswordValidationLabel_shouldBeUpdated_onValidation_andOnChange() {
        let mockUseCase = MockNewPasswordUseCase()
        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        func assertOnChange(
            whenIssues newPasswordIssues: NewPasswordIssues = [],
            passwordStrength: PasswordStrengthEntity = .medium,
            didPressButton: Bool = false,
            validationLabelShouldBe expectedLabel: NewPasswordFieldViewModel.ValidationLabel
        ) {
            mockUseCase._validation = .sample(
                newPasswordIssues: newPasswordIssues,
                passwordStrength: passwordStrength
            )
            sut.newPassword = .random()
            if didPressButton {
                _ = sut.passwordValidity()
            }
            #expect(
                sut.newPasswordValidationLabel ==
                expectedLabel
            )
        }

        assertOnChange(
            whenIssues: .lessThanMinimumCharacters,
            passwordStrength: .weak,
            validationLabelShouldBe: .information(
                NewPasswordFieldViewModel.newPasswordMinimumCharacterText
            )
        )

        assertOnChange(
            whenIssues: .lessThanMinimumCharacters,
            passwordStrength: .weak,
            didPressButton: true,
            validationLabelShouldBe: .error(
                NewPasswordFieldViewModel.newPasswordMinimumCharacterText
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .weak,
            validationLabelShouldBe: .warning(
                SharedStrings.Localizable.Account.NewPassword.weakPassword
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .weak,
            didPressButton: true,
            validationLabelShouldBe: .warning(
                SharedStrings.Localizable.Account.NewPassword.weakPassword
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .veryWeak,
            validationLabelShouldBe: .error(
                SharedStrings.Localizable.Account.NewPassword.veryWeakPassword
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .veryWeak,
            didPressButton: true,
            validationLabelShouldBe: .error(
                SharedStrings.Localizable.Account.NewPassword.veryWeakPassword
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .medium,
            validationLabelShouldBe: .fulfilledInformation(
                NewPasswordFieldViewModel.newPasswordMinimumCharacterText
            )
        )

        assertOnChange(
            whenIssues: [],
            passwordStrength: .medium,
            didPressButton: true,
            validationLabelShouldBe: .fulfilledInformation(
                NewPasswordFieldViewModel.newPasswordMinimumCharacterText
            )
        )
    }

    @Test func testConfirmPasswordValidationLabel_shouldBeUpdated_onValidation_andOnChange() {
        let mockUseCase = MockNewPasswordUseCase()
        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        func assertOnChange(
            whenIssues confirmPasswordIssues: ConfirmPasswordIssues = [],
            didPressButton: Bool = false,
            validationLabelShouldBe expectedLabel: NewPasswordFieldViewModel.ValidationLabel?
        ) {
            mockUseCase._validation = .sample(confirmPasswordIssues: confirmPasswordIssues)
            sut.newPassword = .random()
            if didPressButton {
                _ = sut.passwordValidity()
            }
            #expect(
                sut.confirmPasswordValidationLabel ==
                expectedLabel
            )
        }

        assertOnChange(
            whenIssues: .emptyPassword,
            validationLabelShouldBe: nil
        )

        assertOnChange(
            whenIssues: .emptyPassword,
            didPressButton: true,
            validationLabelShouldBe: .error(ConfirmPasswordIssues.emptyPassword.label!)
        )

        let allIssues: ConfirmPasswordIssues = [.emptyPassword, .doesNotMatch]
        assertOnChange(
            whenIssues: allIssues,
            didPressButton: true,
            validationLabelShouldBe: .error(allIssues.highestPriorityError()!.label!)
        )

        assertOnChange(
            whenIssues: .doesNotMatch,
            validationLabelShouldBe: nil
        )

        assertOnChange(
            whenIssues: .doesNotMatch,
            didPressButton: true,
            validationLabelShouldBe: .error(ConfirmPasswordIssues.doesNotMatch.label!)
        )
    }

    @Test func testNewPasswordInfo_whenFocusOnNewPassword_shouldBeShown() {
        let sut = makeSUT()

        sut.focusDidChange(.confirmPassword)
        #expect(sut.showNewPasswordInformation == false)

        sut.focusDidChange(.newPassword)
        #expect(sut.showNewPasswordInformation)
    }

    @Test func testNewPasswordInfo_whenBeingValidated_shouldBeShown() {
        let sut = makeSUT()

        _ = sut.passwordValidity()
        #expect(sut.showNewPasswordInformation)
    }

    @Test func testPasswordValidity_shouldOnlyReturnPassword_ifValid() {
        let mockUseCase = MockNewPasswordUseCase()
        let sut = makeSUT(newPasswordUseCase: mockUseCase)
        sut.onAppear()

        mockUseCase._validation = .sample(newPasswordIssues: .lessThanMinimumCharacters)
        sut.newPassword = .random()
        #expect(sut.passwordValidity() == .invalid)

        mockUseCase._validation = .sample(confirmPasswordIssues: .doesNotMatch)
        sut.newPassword = .random()
        #expect(sut.passwordValidity() == .invalid)

        mockUseCase._validation = .sample(passwordStrength: .veryWeak)
        sut.newPassword = .random()
        #expect(sut.passwordValidity() == .invalid)

        mockUseCase._validation = .sample()
        let validPassword = String.random()
        sut.newPassword = validPassword
        #expect(sut.passwordValidity() == .valid(password: validPassword))

        mockUseCase._validation = .sample(passwordStrength: .weak)
        sut.newPassword = validPassword
        #expect(sut.passwordValidity() == .valid(password: validPassword))
    }

    @Test func testShowValidationError_whenInvoked_shouldClearTextFields() async {
        let sut = makeSUT()

        await confirmation(
            in: Publishers.CombineLatest4(
                sut.$newPassword,
                sut.$confirmPassword,
                sut.$focusField,
                sut.$newPasswordValidationLabel
            ).allSatisfy { !$0.isEmpty && !$1.isEmpty && $2 == .newPassword && $3 == .error("Error") },
            "Wait for textfields to clear out and keyboard to focus on new password and update border color"
        ) {
            sut.showValidationError(with: "Error")
        }

        #expect(sut.newPasswordCustomBorderColor != nil)
    }

    private func makeSUT(
        newPasswordUseCase: some NewPasswordUseCaseProtocol = MockNewPasswordUseCase()
    ) -> NewPasswordFieldViewModel {
        NewPasswordFieldViewModel(newPasswordUseCase: newPasswordUseCase)
    }
}

// MARK: - Mocks

final class MockNewPasswordUseCase:
    MockObject<MockNewPasswordUseCase.Action>,
    NewPasswordUseCaseProtocol {
    enum Action: Equatable {
        case validate(newPassword: String, confirmPassword: String)
    }

    var _validation: NewPasswordValidationEntity

    init(
        validation: NewPasswordValidationEntity = .sample()
    ) {
        self._validation = validation
    }

    func validate(newPassword: String, confirmPassword: String) -> NewPasswordValidationEntity {
        actions.append(.validate(newPassword: newPassword, confirmPassword: confirmPassword))
        return _validation
    }
}

extension NewPasswordValidationEntity {
    static func sample(
        newPasswordIssues: NewPasswordIssues = [],
        confirmPasswordIssues: ConfirmPasswordIssues = [],
        fulfilledRecommendations: PasswordRecommendations = [],
        passwordStrength: PasswordStrengthEntity = .medium
    ) -> Self {
        NewPasswordValidationEntity(
            newPasswordIssues: newPasswordIssues,
            confirmPasswordIssues: confirmPasswordIssues,
            fulfilledRecommendations: fulfilledRecommendations,
            passwordStrength: passwordStrength
        )
    }
}
