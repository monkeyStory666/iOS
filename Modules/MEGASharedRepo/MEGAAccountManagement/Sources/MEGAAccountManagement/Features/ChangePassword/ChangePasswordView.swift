// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAuthentication
import MEGADesignToken
import MEGAPresentation
import MEGAUIComponent
import MEGASharedRepoL10n
import SwiftUI

public struct ChangePasswordView: View {
    @StateObject private var viewModel: ChangePasswordViewModel
    @StateObject private var newPasswordViewModel: NewPasswordFieldViewModel

    public init(
        viewModel: @autoclosure @escaping () -> ChangePasswordViewModel,
        newPasswordViewModel: @autoclosure @escaping () -> NewPasswordFieldViewModel =
        MEGAAuthentication.DependencyInjection.newPasswordFieldViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        _newPasswordViewModel = StateObject(wrappedValue: newPasswordViewModel())
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: TokenSpacing._7) {
                NewPasswordField(
                    passwordLabel: SharedStrings.Localizable.Account.ChangePassword.newPasswordLabel,
                    viewModel: newPasswordViewModel,
                    onSubmit: didTapChangePassword
                )
                .modifySizeClass(horizontalSizeClass: .regular) { view in
                    // Adds extra padding in this case (specially for iPad landscape) so that
                    // the password fields don't overlap with the toolbar UI when the keyboard
                    // is active
                    view.padding(.top, TokenSpacing._12)
                }
                MEGAButton(
                    SharedStrings.Localizable.Account.ChangePassword.button,
                    state: viewModel.buttonState
                ) {
                    didTapChangePassword()
                }
            }
            .padding(.horizontal, TokenSpacing._5)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: viewModel.didTapDismiss) {
                    XmarkCloseButton()
                }
            }
        }
        .navigationLink(
            unwrap: $viewModel.route.case(/ChangePasswordViewModel.Route.presentTwoFA)
        ) { $viewModel in
            TwoFactorAuthenticationView(viewModel: $viewModel.wrappedValue)
        }
        .onChange(of: viewModel.validationError) { newValue in
            if let newValue {
                newPasswordViewModel.showValidationError(with: newValue)
            }
        }
        .onChange(of: newPasswordViewModel.newPasswordValidationLabel) { newValue in
            if let error = viewModel.validationError,
               newValue != .error(error),
                viewModel.validationError != nil {
                viewModel.validationError = nil
            }
        }
    }

    private func didTapChangePassword() {
        Task {
            await viewModel.didTapChangePassword(
                with: newPasswordViewModel.passwordValidity()
            )
        }
    }
}
