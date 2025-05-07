// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAUIComponent
import MEGADesignToken
import MEGASharedRepoL10n
import SwiftUI

public struct NewPasswordField: View {
    public var passwordLabel: String
    public var confirmPasswordLabel: String
    public var onSubmit: (() -> Void)?

    public let passwordFieldId: String
    public let confirmPasswordFieldId: String
    private let spacing: CGFloat

    @FocusState private var focusedField: NewPasswordFieldViewModel.FormField?

    @StateObject private var viewModel: NewPasswordFieldViewModel

    public init(
        passwordLabel: String = SharedStrings.Localizable.Account.NewPassword.passwordLabel,
        confirmPasswordLabel: String = SharedStrings.Localizable.Account.NewPassword.confirmPasswordLabel,
        passwordFieldId: String =  SharedStrings.Localizable.Account.NewPassword.passwordLabel,
        confirmPasswordFieldId: String = SharedStrings.Localizable.Account.NewPassword.confirmPasswordLabel,
        viewModel: @autoclosure @escaping () -> NewPasswordFieldViewModel = DependencyInjection.newPasswordFieldViewModel,
        spacing: CGFloat = TokenSpacing._7,
        onSubmit: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.passwordLabel = passwordLabel
        self.spacing = spacing
        self.confirmPasswordLabel = confirmPasswordLabel
        self.passwordFieldId = passwordFieldId
        self.confirmPasswordFieldId = confirmPasswordFieldId
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(spacing: spacing) {
            Group {
                newPasswordField
                    .submitLabel(.next)
                confirmPasswordField
                    .submitLabel(.done)
            }
            .onSubmit(of: .text, onSubmitKeyboard)
        }
        .onChange(of: focusedField) {
            viewModel.focusDidChange($0)
        }
        .onChange(of: viewModel.focusField) {
            focusedField = $0
        }
        .onAppear { viewModel.onAppear() }
    }

    private var newPasswordField: some View {
        MEGAFormRow(passwordLabel) {
            MEGAInputField(
                shouldSecure: $viewModel.hideNewPassword,
                protectedText: $viewModel.newPassword
            )
            .borderColor(viewModel.newPasswordCustomBorderColor)
            .textContentType(.newPassword)
            .id(passwordFieldId)
            .tint(TokenColors.Text.primary.swiftUI)
        } footer: {
            if viewModel.showNewPasswordInformation {
                newPasswordFieldInformation
            }
        }
        .focused($focusedField, equals: .newPassword)
    }

    private var newPasswordFieldInformation: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._5) {
            if let label = viewModel.newPasswordValidationLabel {
                validationLabel(label)
            }
            passwordRecommendations
        }
    }

    private var confirmPasswordField: some View {
        MEGAFormRow(confirmPasswordLabel) {
            MEGAInputField(
                shouldSecure: $viewModel.hideConfirmPassword,
                protectedText: $viewModel.confirmPassword
            )
            .borderColor(viewModel.confirmPasswordCustomBorderColor)
            .textContentType(.newPassword)
            .id(confirmPasswordFieldId)
            .tint(TokenColors.Text.primary.swiftUI)
        } footer: {
            if let label = viewModel.confirmPasswordValidationLabel {
                validationLabel(label)
            }
        }
        .focused($focusedField, equals: .confirmPassword)
    }

    private func validationLabel(
        _ validationLabel: NewPasswordFieldViewModel.ValidationLabel
    ) -> some View {
        Group {
            switch validationLabel {
            case .information(let informationText):
                ImageLabel(information: informationText)
            case .error(let errorText):
                ImageLabel(error: errorText)
            case .warning(let warningText):
                ImageLabel(warning: warningText)
            case .fulfilledInformation(let informationText):
                ImageLabel(information: informationText)
                    .icon { Image.checkMarkCircle }
                    .iconColor(TokenColors.Support.success.swiftUI)
            }
        }
    }

    private var passwordRecommendations: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._4) {
            Text(SharedStrings.Localizable.Account.NewPassword.betterToHave)
                .font(.footnote.bold())
            VStack(alignment: .leading, spacing: TokenSpacing._2) {
                ForEach(viewModel.recommendationFulfillment, id: \.label) {
                    recommendationLabel($0.label, isFulfilled: $0.isFulfilled)
                }
            }
            .font(.footnote)
        }
        .foregroundStyle(TokenColors.Text.secondary.swiftUI)
    }

    private func recommendationLabel(
        _ string: String,
        isFulfilled: Bool
    ) -> some View {
        ImageLabel(
            string,
            textColor: TokenColors.Text.secondary.swiftUI,
            iconColor: TokenColors.Text.secondary.swiftUI
        ) {
            AnyView(recommendationBullet)
        }
        .icon({ AnyView(Image.checkMark) }, isFulfilled)
        .iconColor(TokenColors.Support.success.swiftUI, isFulfilled)
    }

    private var recommendationBullet: some View {
        Image.circle
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 4, height: 4)
            .frame(width: 16, height: 16, alignment: .center)
    }

    private func onSubmitKeyboard() {
        switch focusedField {
        case .newPassword:
            focusedField = .confirmPassword
        default:
            focusedField = nil
            onSubmit?()
        }
    }
}

struct NewPasswordField_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var viewModel = DependencyInjection.newPasswordFieldViewModel

        var body: some View {
            VStack {
                NewPasswordField(viewModel: viewModel)
                MEGAButton("Check Password") {
                    _ = viewModel.passwordValidity()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
        }
    }

    static var previews: some View {
        Preview()
    }
}
