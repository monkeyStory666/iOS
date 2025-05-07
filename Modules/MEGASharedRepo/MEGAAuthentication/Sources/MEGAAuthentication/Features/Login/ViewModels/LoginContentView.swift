import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct LoginContentView<ViewModel: LoginContentViewModelProtocol>: View {
    public enum FormField: Hashable {
        case username
        case password
    }
    
    @ObservedObject var viewModel: ViewModel
    @FocusState private var focusedField: FormField?
    
    public init(
        viewModel: ViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if #available(iOS 16.4, *) {
                loginScrollView
                    .scrollIndicators(.visible)
                    .scrollBounceBehavior(.basedOnSize)
            } else {
                loginScrollView
            }
        }
    }
    
    private var loginScrollView: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(
                        spacing: Constants.isPad
                        ? TokenSpacing._17
                        : TokenSpacing._14
                    ) {
                        LoginHeaderView()
                        if Constants.isPad {
                            loginContentView(scrollViewProxy)
                                .frame(maxHeight: .infinity, alignment: .top)
                        } else {
                            loginContentView(scrollViewProxy)
                        }
                    }
                    .padding(TokenSpacing._5)
                    .maxWidthForWideScreen()
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
                .pageBackground()
            }
        }
    }
    
    private func loginContentView(_ scrollViewProxy: ScrollViewProxy) -> some View {
        VStack(
            spacing: Constants.isMacCatalyst
            ? TokenSpacing._5
            : TokenSpacing._11
        ) {
            LoginUsernameAndPasswordFormView(
                viewModel: viewModel,
                focusedField: $focusedField,
                scrollViewProxy: scrollViewProxy
            )
            LoginButtonsView(viewModel: viewModel, focusedField: $focusedField)
        }
    }
}

private struct LoginButtonsView<ViewModel: LoginContentViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState.Binding var focusedField: LoginContentView<ViewModel>.FormField?

    var body: some View {
        VStack(
            spacing: Constants.isMacCatalyst
            ? TokenSpacing._9
            : TokenSpacing._11
        ) {
            VStack(spacing: TokenSpacing._5) {
                MEGAButton(
                    SharedStrings.Localizable.Login.verifyButtonTitle,
                    state: viewModel.buttonState
                ) {
                    focusedField = nil
                    Task {
                        await viewModel.didTapLogin()
                    }
                }
                Link(destination: Constants.Link.forgotPassword) {
                    MEGAButton(
                        SharedStrings.Localizable.Login.forgotPasswordButtonTitle,
                        type: .textOnly
                    )
                }
            }
            if viewModel.shouldShowSignUpButton {
                AttributedTextView(
                    stringAttribute: .init(
                        text: SharedStrings.Localizable.Login.signupButtonTitle
                            .removeAllLocalizationTags(),
                        font: .callout,
                        foregroundColor: .primary),
                    substringAttributeList: [
                        .init(
                            text: SharedStrings.Localizable.Login.signupButtonTitle
                                .getLocalizationSubstring(tag: "L"),
                            attributes: AttributeContainer()
                                .font(.callout.weight(.semibold))
                                .foregroundColor(TokenColors.Link.primary.swiftUI),
                            action: viewModel.didTapSignUp
                        )
                    ]
                )
            }
        }
    }
}

private struct LoginUsernameAndPasswordFormView<ViewModel: LoginContentViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState.Binding var focusedField: LoginContentView<ViewModel>.FormField?
    var scrollViewProxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: TokenSpacing._5) {
            UserNameTextFieldView(viewModel: viewModel, focusedField: $focusedField)
                .submitLabel(.next)
                .id(SharedStrings.Localizable.Login.email)
            PasswordTextFieldView(viewModel: viewModel, focusedField: $focusedField)
                .submitLabel(.done)
                .id(SharedStrings.Localizable.Login.password)

            if let subtitle = viewModel.errorBannerSubtitle {
                MEGABanner(subtitle: subtitle, state: .error)
            }
        }
        .onSubmit(of: .text) {
            guard let current = focusedField else { return }

            switch current {
            case .username:
                focusedField = .password
            case .password:
                focusedField = nil
                Task { await viewModel.didTapLogin() }
            }
        }
        .onChange(of: focusedField) { currentFocusField in
            guard let currentFocusField, !Constants.isMacCatalyst else { return }
            let id: String

            switch currentFocusField {
            case .username:
                id = SharedStrings.Localizable.Login.email
            case .password:
                id = SharedStrings.Localizable.Login.password
            }

            scrollViewProxy.textFieldKeyboardAvoidance(scrollTo: id)
        }
    }
}

private struct UserNameTextFieldView<ViewModel: LoginContentViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState.Binding var focusedField: LoginContentView<ViewModel>.FormField?

    var body: some View {
        MEGAFormRow(SharedStrings.Localizable.Login.email) {
            MEGAInputField(clearableText: Binding(get: {
                viewModel.username
            }, set: {
                viewModel.username = $0
            })) { inputField in
                inputField
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .username)
            }
            .borderColor(
                TokenColors.Support.error.swiftUI,
                viewModel.usernameFieldState.isWarning
            )
        } footer: { _ in
            if case .warning(let label) = viewModel.usernameFieldState, !label.isEmpty {
                ImageLabel(error: label)
            }
        }
    }
}

private struct PasswordTextFieldView<ViewModel: LoginContentViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState.Binding var focusedField: LoginContentView<ViewModel>.FormField?

    var body: some View {
        MEGAFormRow(SharedStrings.Localizable.Login.password) {
            MEGAInputField(
                shouldSecure: Binding(get: {
                    viewModel.shouldSecurePassword
                }, set: {
                    viewModel.shouldSecurePassword = $0
                }),
                protectedText: Binding(get: {
                    viewModel.password
                }, set: {
                    viewModel.password = $0
                })
            ) { inputField in
                inputField
                    .focused($focusedField, equals: .password)
            }
            .borderColor(
                TokenColors.Support.error.swiftUI,
                viewModel.passwordFieldState.isWarning
            )
        } footer: { _ in
            if case .warning(let label) = viewModel.passwordFieldState, !label.isEmpty {
                ImageLabel(error: label)
            }
        }
    }
}
