// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAPresentation
import MEGAUIComponent
import MEGASharedRepoL10n
import SwiftUI

public struct ChangeNameView: View {
    enum FormField: Hashable {
        case firstName
        case lastName
    }

    @FocusState private var focusedField: FormField?

    @StateObject private var viewModel: ChangeNameViewModel

    public init(viewModel: @autoclosure @escaping () -> ChangeNameViewModel = ChangeNameViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(spacing: TokenSpacing._7) {
            MEGAFormRow(SharedStrings.Localizable.Account.ChangeName.firstName) {
                MEGAInputField(clearableText: $viewModel.firstName) { inputField in
                    inputField
                        .maxCharacterLimit($viewModel.firstName, to: viewModel.nameMaxCharacterLimit)
                        .textContentType(.givenName)
                        .focused($focusedField, equals: .firstName)
                }
                .borderColor(
                    TokenColors.Support.error.swiftUI,
                    viewModel.firstNameFieldState.isWarning
                )
                .tint(TokenColors.Text.primary.swiftUI)
            } footer: { _ in
                if case .warning(let label) = viewModel.firstNameFieldState {
                    ImageLabel(error: label)
                }
            }
            .submitLabel(.next)
            MEGAFormRow(SharedStrings.Localizable.Account.ChangeName.lastName) {
                MEGAInputField(clearableText: $viewModel.lastName) { inputField in
                    inputField
                        .maxCharacterLimit($viewModel.lastName, to: viewModel.nameMaxCharacterLimit)
                        .textContentType(.familyName)
                        .focused($focusedField, equals: .lastName)
                }
                .borderColor(
                    TokenColors.Support.error.swiftUI,
                    viewModel.lastNameFieldState.isWarning
                )
                .tint(TokenColors.Text.primary.swiftUI)
            } footer: { _ in
                if case .warning(let label) = viewModel.lastNameFieldState {
                    ImageLabel(error: label)
                }
            }
            .submitLabel(.done)
            MEGAButton(
                SharedStrings.Localizable.Account.ChangeName.update,
                state: viewModel.buttonState
            ) {
                didTapUpdate()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: viewModel.didTapDismiss) {
                    XmarkCloseButton()
                }
            }
        }
        .padding(.horizontal, TokenSpacing._5)
        .task { await viewModel.onAppear() }
        .onSubmit(of: .text) {
            guard let current = focusedField else { return }

            switch current {
            case .firstName:
                focusedField = .lastName
            case .lastName:
                focusedField = nil
                didTapUpdate()
            }
        }
    }

    private func didTapUpdate() {
        Task {
            await viewModel.didTapUpdate()
        }
    }
}

struct ChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationViewStack {
            ChangeNameView(viewModel: viewModel)
                .frame(
                    maxHeight: .infinity,
                    alignment: .top
                )
                .navigationTitle("Change Name")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    static var viewModel: ChangeNameViewModel {
        let viewModel = ChangeNameViewModel()
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        return viewModel
    }
}
