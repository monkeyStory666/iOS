// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct ChangeEmailView: View {
    @StateObject private var viewModel: ChangeEmailViewModel

    init(viewModel: @autoclosure @escaping () -> ChangeEmailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._5) {
            Text(SharedStrings.Localizable.ChangeEmail.message)
                .padding(.top, TokenSpacing._7)

            EmailTextFieldView(viewModel: viewModel)

            MEGAButton(
                SharedStrings.Localizable.ChangeEmail.update,
                state: viewModel.buttonState
            ) {
                Task {
                    await viewModel.updateButtonTapped()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: viewModel.didTapBackButton) {
                    BackChevron()
                }
            }
        }
        .allowsHitTesting(viewModel.buttonState != .load)
        .maxWidthForWideScreen()
        .padding(TokenSpacing._5)
        .pageBackground(alignment: .top)
        .background(TokenColors.Background.page.swiftUI)
        .onAppear(perform: viewModel.onViewAppear)
        .alert(unwrapModel: $viewModel.alertToPresent)
    }
}

private struct EmailTextFieldView: View {
    @ObservedObject var viewModel: ChangeEmailViewModel

    var body: some View {
        MEGAFormRow(SharedStrings.Localizable.ChangeEmail.Textfield.title) {
            MEGAInputField(clearableText: $viewModel.email) { inputField in
                inputField
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
            }
            .borderColor(
                TokenColors.Support.error.swiftUI,
                viewModel.emailFieldState.isWarning
            )
        } footer: { _ in
            if case .warning(let label) = viewModel.emailFieldState {
                ImageLabel(error: label)
            }
        }
    }
}

struct ChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailView(
            viewModel: DependencyInjection.changeEmailViewModel(name: "", email: "")
        )
    }
}
