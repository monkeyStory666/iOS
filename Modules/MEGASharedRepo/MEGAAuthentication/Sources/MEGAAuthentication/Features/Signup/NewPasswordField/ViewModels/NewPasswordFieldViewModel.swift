// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGADesignToken
import MEGAUIComponent
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class NewPasswordFieldViewModel: NoRouteViewModel {
    public enum FormField: Hashable {
        case newPassword
        case confirmPassword
    }

    public enum ValidationLabel: Equatable {
        case information(String)
        case error(String)
        case warning(String)
        case fulfilledInformation(String)
    }

    @Published public var newPassword = ""
    @ViewProperty public var hideNewPassword = true
    @ViewProperty public var showNewPasswordInformation = false
    @ViewProperty public var focusField: FormField?
    @ViewProperty public var newPasswordCustomBorderColor: Color?
    @ViewProperty public var newPasswordValidationLabel: ValidationLabel? = .information(
        NewPasswordFieldViewModel.newPasswordMinimumCharacterText
    )

    @Published public var confirmPassword = ""
    @ViewProperty public var hideConfirmPassword = true
    @ViewProperty public var confirmPasswordCustomBorderColor: Color?
    @ViewProperty public var confirmPasswordValidationLabel: ValidationLabel?

    @ViewProperty public var validation: NewPasswordValidationEntity?

    public struct RecommendationFulfillment {
        let label: String
        let isFulfilled: Bool
    }

    public var recommendationFulfillment: [RecommendationFulfillment] {
        let recommendations: [PasswordRecommendations] = [
            .upperAndLowercaseLetters,
            .oneNumberOrSpecialCharacter
        ]

        return recommendations.compactMap {
            guard let label = $0.label else { return nil }

            return .init(
                label: label,
                isFulfilled: validation?.fulfilledRecommendations.contains($0) ?? false
            )
        }
    }

    public static var newPasswordMinimumCharacterText: String {
        SharedStrings.Localizable.Account.NewPassword.minimumCharacter
    }

    private let newPasswordUseCase: any NewPasswordUseCaseProtocol

    public init(newPasswordUseCase: some NewPasswordUseCaseProtocol) {
        self.newPasswordUseCase = newPasswordUseCase
        super.init()
    }

    func onAppear() {
        observeChanges()
    }

    public func passwordValidity() -> PasswordValidity {
        showNewPasswordInformation = true
        updateFieldStates()

        return validation?.isValid == true
            ? .valid(password: newPassword)
            : .invalid
    }

    public func focusDidChange(_ focus: FormField?) {
        switch focus {
        case .newPassword:
            showNewPasswordInformation = true
        default:
            break
        }

        focusField = focus
    }

    public func resetFieldStatus() {
        onChange(newPassword, confirmPassword)
    }

    public func showValidationError(with message: String) {
        DispatchQueue.main.async {
            self.newPassword = ""
            self.confirmPassword = ""
            self.focusField = .newPassword
            self.newPasswordCustomBorderColor = self.borderColor(hasError: true)
            self.newPasswordValidationLabel = .error(message)
        }
    }

    // MARK: - Private methods

    private func observeChanges() {
        observe {
            Publishers
                .CombineLatest($newPassword, $confirmPassword)
                .removeDuplicates { $0 == $1 }
                .sink { [weak self] in
                    self?.onChange($0, $1)
                }
        }
    }

    private func onChange(
        _ newPassword: String,
        _ confirmPassword: String
    ) {
        confirmPasswordCustomBorderColor = nil
        confirmPasswordValidationLabel = nil

        let validation = validate(newPassword, confirmPassword)
        updateNewPasswordValidationLabelOnChange(validation)
        updateNewPasswordValidationCustomBorderColor(validation)
    }

    private func updateNewPasswordValidationCustomBorderColor(_ validation: NewPasswordValidationEntity) {
        guard validation.newPasswordIssues != .lessThanMinimumCharacters else {
            newPasswordCustomBorderColor = nil
            return
        }

        if !validation.passwordStrength.isValidPassword {
            newPasswordCustomBorderColor = borderColor(hasError: true)
        } else {
            newPasswordCustomBorderColor = nil
        }
    }

    private func validate(
        _ newPassword: String,
        _ confirmPassword: String
    ) -> NewPasswordValidationEntity {
        let validation = newPasswordUseCase.validate(
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
        self.validation = validation
        return validation
    }

    private func updateNewPasswordValidationLabelOnChange(_ validation: NewPasswordValidationEntity) {
        if case .lessThanMinimumCharacters = validation.newPasswordIssues {
            newPasswordValidationLabel = .information(Self.newPasswordMinimumCharacterText)
        } else if !validation.passwordStrength.isValidPassword {
            newPasswordValidationLabel = .error(SharedStrings.Localizable.Account.NewPassword.veryWeakPassword)
        } else if validation.passwordStrength.isWeakPassword {
            newPasswordValidationLabel = .warning(SharedStrings.Localizable.Account.NewPassword.weakPassword)
        } else {
            newPasswordValidationLabel = .fulfilledInformation(Self.newPasswordMinimumCharacterText)
        }
    }

    private func updateFieldStates() {
        guard let validation else { return }

        updateNewPasswordBorderColor(validation)
        updateNewPasswordValidationLabel(validation)
        updateConfirmPasswordBorderColor(validation)
        updateConfirmPasswordValidationLabel(validation)
    }

    private func updateNewPasswordBorderColor(_ validation: NewPasswordValidationEntity) {
        newPasswordCustomBorderColor = borderColor(hasError: !validation.newPasswordIssues.isEmpty
                                                   || !validation.passwordStrength.isValidPassword)
    }

    private func updateNewPasswordValidationLabel(_ validation: NewPasswordValidationEntity) {
        if case .lessThanMinimumCharacters = validation.newPasswordIssues {
            newPasswordValidationLabel = .error(Self.newPasswordMinimumCharacterText)
        } else if !validation.passwordStrength.isValidPassword {
            newPasswordValidationLabel = .error(SharedStrings.Localizable.Account.NewPassword.veryWeakPassword)
        } else if validation.passwordStrength.isWeakPassword {
            newPasswordValidationLabel = .warning(SharedStrings.Localizable.Account.NewPassword.weakPassword)
        } else {
            newPasswordValidationLabel = .fulfilledInformation(Self.newPasswordMinimumCharacterText)
        }
    }

    private func updateConfirmPasswordBorderColor(_ validation: NewPasswordValidationEntity) {
        confirmPasswordCustomBorderColor = borderColor(hasError: !validation.confirmPasswordIssues.isEmpty)
    }

    private func updateConfirmPasswordValidationLabel(_ validation: NewPasswordValidationEntity) {
        if let errorLabel = validation.confirmPasswordIssues.label {
            confirmPasswordValidationLabel = .error(errorLabel)
        } else {
            confirmPasswordValidationLabel = nil
        }
    }

    private func borderColor(hasError: Bool) -> Color? {
        hasError ? TokenColors.Support.error.swiftUI : nil
    }
}

extension PasswordRecommendations {
    var label: String? {
        switch self {
        case .upperAndLowercaseLetters:
            return SharedStrings.Localizable.Account.NewPassword.upperAndLowerCase
        case .oneNumberOrSpecialCharacter:
            return SharedStrings.Localizable.Account.NewPassword.oneNumberOrSpecial
        default:
            return nil
        }
    }
}

extension ConfirmPasswordIssues {
    var label: String? {
        switch highestPriorityError() {
        case .some(.emptyPassword):
            return SharedStrings.Localizable.Account.NewPassword.confirmPasswordError
        case .some(.doesNotMatch):
            return SharedStrings.Localizable.Account.NewPassword.passwordDoNotMatch
        default:
            return nil
        }
    }
}
