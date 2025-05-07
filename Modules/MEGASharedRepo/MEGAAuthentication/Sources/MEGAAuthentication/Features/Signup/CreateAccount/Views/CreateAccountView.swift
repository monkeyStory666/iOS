// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import Foundation
import MEGAConnectivity
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift
import MEGAUIComponent
import SwiftUI

public struct CreateAccountView: View {
    public enum FormField: Hashable {
        case firstName
        case lastName
        case email
    }
    
    @StateObject private var viewModel: CreateAccountViewModel
    @StateObject private var newPasswordViewModel = DependencyInjection.newPasswordFieldViewModel

    @FocusState private var focusedField: FormField?
    @State private var previousFocusedField: FormField?

    public init(
        viewModel: @autoclosure @escaping () -> CreateAccountViewModel = DependencyInjection.createAccountViewModel,
        newPasswordViewModel: @autoclosure @escaping () -> NewPasswordFieldViewModel = DependencyInjection.newPasswordFieldViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        _newPasswordViewModel = StateObject(wrappedValue: newPasswordViewModel())
    }
    
    public var body: some View {
        NavigationViewStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: TokenSpacing._7) {
                        TextFieldsView(
                            viewModel: viewModel,
                            newPasswordViewModel: newPasswordViewModel,
                            focusedField: $focusedField,
                            scrollViewProxy: proxy
                        )
                        TermsAndConditionView(viewModel: viewModel)
                        CreateAccountButtonView(viewModel: viewModel, newPasswordViewModel: newPasswordViewModel)
                        LoginActionView(viewModel: viewModel)
                    }
                    .padding(TokenSpacing._5)
                }
                .onSubmit(of: .text) {
                    guard let current = focusedField else { return }
                    
                    switch current {
                    case .firstName:
                        focusedField = .lastName
                    case .lastName:
                        focusedField = .email
                    case .email:
                        newPasswordViewModel.focusField = .newPassword
                    }
                }
                .maxWidthForWideScreen()
                .pageBackground()
            }
            .navigationTitle(SharedStrings.Localizable.CreateAccount.Navigation.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: viewModel.didTapDismiss) {
                        XmarkCloseButton()
                    }
                }
            }
            .navigationLink(
                unwrap: $viewModel.route.case(/CreateAccountViewModel.Route.emailConfirmation)
            ) { viewModel in
                CreateAccountEmailSentView(viewModel: viewModel.wrappedValue)
            }
        }
        .noInternetViewModifier()
        .onAppear {
            viewModel.onViewAppear()
        }
        .onChange(of: viewModel.isTermsAndConditionsChecked) { _ in
            viewModel.termsAndConditionsFieldState = .normal
        }
        .onChange(
            of: newPasswordViewModel.newPasswordCustomBorderColor, perform: clearFieldStatus(with:)
        )
        .onChange(
            of: newPasswordViewModel.confirmPasswordCustomBorderColor, perform: clearFieldStatus(with:)
        )
        .onChange(of: viewModel.firstName) { _ in
            viewModel.firstNameFieldState = .normal
        }
        .onChange(of: viewModel.lastName) { _ in
            viewModel.lastNameFieldState = .normal
        }
        .onChange(of: viewModel.email) { _ in
            viewModel.emailFieldState = .normal
        }
    }

    private func clearFieldStatus(with borderColor: Color?) {
        guard borderColor == nil else { return }
        newPasswordViewModel.resetFieldStatus()
    }
}

private struct TextFieldsView: View {
    @ObservedObject var viewModel: CreateAccountViewModel
    @ObservedObject var newPasswordViewModel: NewPasswordFieldViewModel
    @FocusState.Binding var focusedField: CreateAccountView.FormField?
    let scrollViewProxy: ScrollViewProxy
    
    var body: some View {
        VStack(spacing: TokenSpacing._5) {
            Group {
            #if targetEnvironment(macCatalyst)
                HStack(alignment: .top, spacing: TokenSpacing._5) {
                    firstNameField
                    lastNameField
                }
            #else
                firstNameField
                lastNameField
            #endif
                emailField
                newPasswordField
            }
            .submitLabel(.next)
        }
        .onChange(of: focusedField) { currentFocusField in
            guard let currentFocusField, !Constants.isMacCatalyst else { return }
            let id: String

            switch currentFocusField {
            case .firstName:
                id = SharedStrings.Localizable.CreateAccount.FirstNameTextField.title
            case .lastName:
                id = SharedStrings.Localizable.CreateAccount.LastNameTextField.title
            case .email:
                id = SharedStrings.Localizable.CreateAccount.EmailTextField.title
            }

            scrollViewProxy.textFieldKeyboardAvoidance(scrollTo: id)
        }
        .onChange(of: newPasswordViewModel.focusField) { currentFocusField in
            guard let currentFocusField else { return }
            let id: String
            switch currentFocusField {
            case .newPassword:
                id = SharedStrings.Localizable.CreateAccount.PasswordTextField.title
            case .confirmPassword:
                id = SharedStrings.Localizable.CreateAccount.ConfirmPasswordTextField.title
            }
            scrollViewProxy.textFieldKeyboardAvoidance(scrollTo: id)
        }
    }
    
    private var firstNameField: some View {
        PlainTextFieldView(
            title: SharedStrings.Localizable.CreateAccount.FirstNameTextField.title,
            formField: .firstName,
            fieldState: viewModel.firstNameFieldState,
            autocapitalization: .words,
            textContentType: .givenName,
            maxCharacterLimit: viewModel.nameMaxCharacterLimit,
            inputText: $viewModel.firstName,
            focusedField: $focusedField
        )
        .id(SharedStrings.Localizable.CreateAccount.FirstNameTextField.title)
    }
    
    private var lastNameField: some View {
        PlainTextFieldView(
            title: SharedStrings.Localizable.CreateAccount.LastNameTextField.title,
            formField: .lastName,
            fieldState: viewModel.lastNameFieldState,
            autocapitalization: .words,
            textContentType: .familyName,
            maxCharacterLimit: viewModel.nameMaxCharacterLimit,
            inputText: $viewModel.lastName,
            focusedField: $focusedField
        )
        .id(SharedStrings.Localizable.CreateAccount.LastNameTextField.title)
    }
    
    private var emailField: some View {
        PlainTextFieldView(
            title: SharedStrings.Localizable.CreateAccount.EmailTextField.title,
            formField: .email,
            fieldState: viewModel.emailFieldState,
            autocapitalization: .none,
            textContentType: .username,
            keyboardType: .emailAddress,
            inputText: $viewModel.email,
            focusedField: $focusedField
        )
        .id(SharedStrings.Localizable.CreateAccount.EmailTextField.title)
    }
    
    private var newPasswordField: some View {
        NewPasswordField(
            passwordLabel: SharedStrings.Localizable.CreateAccount.PasswordTextField.title,
            confirmPasswordLabel: SharedStrings.Localizable.CreateAccount.ConfirmPasswordTextField.title,
            passwordFieldId: SharedStrings.Localizable.CreateAccount.PasswordTextField.title,
            confirmPasswordFieldId: SharedStrings.Localizable.CreateAccount.ConfirmPasswordTextField.title,
            viewModel: newPasswordViewModel,
            spacing: TokenSpacing._5
        )
    }
}

private struct TermsAndConditionView: View {
    @ObservedObject var viewModel: CreateAccountViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._3) {
            Button {
                viewModel.isTermsAndConditionsChecked.toggle()
            } label: {
                HStack(spacing: TokenSpacing._3) {
                    MEGAChecklist(
                        state: .default,
                        isChecked: $viewModel.isTermsAndConditionsChecked
                    )
                    Text(.init(
                        SharedStrings.Localizable.CreateAccount.TermsOfService.message
                            .assignLink(Constants.Link.megaTermsOfService)
                    ))
                    .font(.footnote)
                    .foregroundColor(TokenColors.Text.primary.swiftUI)
                    .tint(TokenColors.Link.primary.swiftUI)
                }
            }
            .buttonStyle(.plain)
            
            if case .warning(let error) = viewModel.termsAndConditionsFieldState {
                ImageLabel(error: error)
            }
        }
    }
}

private struct LoginActionView: View {
    @ObservedObject var viewModel: CreateAccountViewModel
    
    var body: some View {
        AttributedTextView(
            stringAttribute: .init(
                text: SharedStrings.Localizable.CreateAccount.AccountAlreadyExists.message
                    .removeAllLocalizationTags(),
                font: .callout
            ),
            substringAttributeList: [
                .init(
                    text: SharedStrings.Localizable.CreateAccount.AccountAlreadyExists.message
                        .getLocalizationSubstring(tag: "L"),
                    attributes: AttributeContainer()
                        .font(.callout.weight(.semibold))
                        .foregroundColor(TokenColors.Link.primary.swiftUI),
                    action: viewModel.didTapLogin
                )
            ]
        )
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

private struct CreateAccountButtonView: View {
    @ObservedObject var viewModel: CreateAccountViewModel
    @ObservedObject var newPasswordViewModel: NewPasswordFieldViewModel
    
    var body: some View {
        MEGAButton(
            SharedStrings.Localizable.CreateAccount.buttonTitle,
            state: viewModel.buttonState
        ) {
            Task {
                await viewModel.didTapCreateAccount(with: newPasswordViewModel.passwordValidity())
            }
        }
    }
}

private struct PlainTextFieldView: View {
    let title: String
    let formField: CreateAccountView.FormField
    let fieldState: CreateAccountViewModel.FieldState
    let autocapitalization: UITextAutocapitalizationType
    let textContentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default
    var maxCharacterLimit: Int? = nil
    
    @Binding var inputText: String
    @FocusState.Binding var focusedField: CreateAccountView.FormField?
    
    var body: some View {
        MEGAFormRow(title) {
            MEGAInputField(clearableText: $inputText) { inputField in
                inputField
                    .maxCharacterLimit($inputText, to: maxCharacterLimit)
                    .autocapitalization(autocapitalization)
                    .autocorrectionDisabled()
                    .textContentType(textContentType)
                    .keyboardType(keyboardType)
                    .focused($focusedField, equals: formField)
            }
            .borderColor(
                TokenColors.Support.error.swiftUI,
                fieldState.isWarning
            )
        } footer: { _ in
            if case .warning(let label) = fieldState {
                ImageLabel(error: label)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
