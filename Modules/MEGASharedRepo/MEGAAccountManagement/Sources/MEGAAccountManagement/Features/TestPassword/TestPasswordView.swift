// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGAPresentation
import MEGAUIComponent
import MEGASharedRepoL10n
import SwiftUI

public struct TestPasswordView: View {
    @StateObject private var viewModel: TestPasswordViewModel

    public init(viewModel: @autoclosure @escaping () -> TestPasswordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    @State private var hidePassword = true

    public var body: some View {
        ScrollView {
            VStack(spacing: TokenSpacing._7) {
                Text(SharedStrings.Localizable.TestPassword.information)
                    .font(.callout)
                    .foregroundColor(TokenColors.Text.secondary.swiftUI)
                passwordField
                    .padding(.bottom, TokenSpacing._2)
                forgotPassword
                VStack(spacing: TokenSpacing._5) {
                    testPasswordButton
                    exportRecoveryKeyButton
                }
            }
        }
        .padding(.horizontal, TokenSpacing._5)
        .onAppear { viewModel.onAppear() }
        .dynamicSheet(
            unwrap: $viewModel.route
                .case(/TestPasswordViewModel.Route.forgotPassword)
        ) { changePasswordViewModel in
            changePasswordView(changePasswordViewModel.wrappedValue)
        }
    }

    private func changePasswordView(
        _ changePasswordViewModel: ChangePasswordViewModel
    ) -> some View {
        NavigationViewStack {
            ChangePasswordView(viewModel: changePasswordViewModel)
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationTitle(SharedStrings.Localizable.Settings.AccountDetail.changePassword)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    var passwordField: some View {
        MEGAFormRow(SharedStrings.Localizable.TestPassword.fieldTitle) {
            MEGAInputField(
                shouldSecure: $hidePassword,
                protectedText: $viewModel.password
            )
            .borderColor(
                TokenColors.Text.success.swiftUI,
                viewModel.testingState == .correct
            )
            .borderColor(
                TokenColors.Text.error.swiftUI,
                viewModel.testingState == .incorrect
            )
        } footer: { _ in
            switch viewModel.testingState {
            case .correct:
                ImageLabel(success: SharedStrings.Localizable.TestPassword.correct)
            case .incorrect:
                ImageLabel(error: SharedStrings.Localizable.TestPassword.incorrect)
            default:
                EmptyView()
            }
        }
        .submitLabel(.return)
        .onSubmit(of: .text) {
            Task { await viewModel.didTestPassword() }
        }
        .frame(height: 80, alignment: .top)
    }

    var forgotPassword: some View {
        Button {
            viewModel.didForgotPassword()
        } label: {
            HStack(spacing: TokenSpacing._2) {
                Image("helpCircleSmallRegularOutline", bundle: .module)
                Text(SharedStrings.Localizable.TestPassword.forgotPassword)
            }
            .font(.callout)
            .foregroundColor(TokenColors.Link.primary.swiftUI)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var testPasswordButton: some View {
        MEGAButton(
            SharedStrings.Localizable.TestPassword.buttonTitle,
            state: viewModel.buttonState
        ) {
            Task { await viewModel.didTestPassword() }
        }
    }

    private var exportRecoveryKeyButton: some View {
        MEGAButton(
            SharedStrings.Localizable.Offboarding.ExportRecoveryKey.buttonTitle,
            type: .secondary
        ) {
            viewModel.didTapExportRecoveryKeyButton()
        }
    }
}
