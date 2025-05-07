// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI
import SwiftUIIntrospect

public typealias SecureAccessory = HStack<TupleView<(Button<Image>?, Button<Image>)>>

/// Extensions providing initializers for a password-protected `MEGAInputField`.
public extension MEGAInputField where Accessory == SecureAccessory? {
    /// Creates a password-protected input field with customizable appearance.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///   - isTextColored: Whether the input text should be colored.
    ///   - viewModifiers: A closure that modifies the appearance and behavior of the secure input field.
    ///   - onSubmitColoredText: A closure that perform actions when user submit a value to the colored textField
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Secure Field") {
    ///     MEGAInputField(protectedText: $secure) { secureField, isFocused in
    ///         secureField.foregroundColor(isFocused ? .red : .blue)
    ///     }
    /// }
    /// ```
    init(
        shouldSecure: Binding<Bool>,
        protectedText input: Binding<String>,
        isTextColored: Bool = false,
        onSubmitColoredText: (() -> Void)? = nil,
        @ViewBuilder fieldAppearance viewModifiers: @escaping (MEGASecureField, IsFocused) -> Field
    ) {
        let secureField = MEGASecureField(
            input: input,
            shouldSecure: shouldSecure,
            isTextColored: isTextColored,
            onSubmitColoredText: onSubmitColoredText
        )

        self.init { isFocused in
            viewModifiers(
                secureField,
                isFocused
            )
        } accessoryBuilder: { isFocused in
            if !input.wrappedValue.isEmpty {
                HStack(spacing: TokenSpacing._5) {
                    if isFocused {
                        secureField.clearButton
                    }
                    
                    secureField.secureButton
                }
            }
        }
    }

    /// Creates a password-protected input field without the need for view modifiers based on focus.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///   - isTextColored: Whether the input text should be colored.
    ///   - onSubmitColoredText: A closure that perform actions when user submit a value to the colored textField
    ///   - viewModifiers: A closure that modifies the appearance and behavior of the secure input field.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Secure Field") {
    ///     MEGAInputField(protectedText: $secure) { secureField in
    ///         secureField.foregroundColor(.blue)
    ///     }
    /// }
    /// ```
    init(
        shouldSecure: Binding<Bool>,
        protectedText input: Binding<String>,
        isTextColored: Bool = false,
        onSubmitColoredText: (() -> Void)? = nil,
        @ViewBuilder fieldAppearance viewModifiers: @escaping (MEGASecureField) -> Field
    ) {
        self.init(
            shouldSecure: shouldSecure,
            protectedText: input,
            isTextColored: isTextColored,
            onSubmitColoredText: onSubmitColoredText,
            fieldAppearance: { secureField, _ in
                viewModifiers(secureField)
            }
        )
    }
}

/// Extensions providing initializers for a password-protected `MEGAInputField`.
public extension MEGAInputField where Field == MEGASecureField, Accessory == SecureAccessory? {
    /// Creates a password-protected input field with default appearance.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Secure Field") {
    ///     MEGAInputField(protectedText: $secure)
    /// }
    /// ```
    init(
        shouldSecure: Binding<Bool>,
        protectedText input: Binding<String>
    ) {
        self.init(
            shouldSecure: shouldSecure,
            protectedText: input,
            fieldAppearance: { secureField, _ in
                secureField
            }
        )
    }
}

/// A view representing a secure text input field with a toggleable visibility option.
public struct MEGASecureField: View {
    @Binding var input: String
    @Binding var shouldSecure: Bool
    let isTextColored: Bool
    let onSubmitColoredText: (() -> Void)?

    var willSecure: Bool { $shouldSecure.wrappedValue }

    enum Focus {
        case secure, text
    }

    @FocusState private var focus: Focus?

    public var body: some View {
        ZStack(alignment: .leading) {
            Group {
                if willSecure {
                    SecureField($input)
                        .focused($focus, equals: .secure)
                } else if isTextColored {
                    ColoredTextField(
                        text: $input,
                        onSubmit: onSubmitColoredText
                    )
                    .focused($focus, equals: .text)
                } else {
                    TextField($input)
                        .introspect(.textField, on: .iOS(.v15, .v16, .v17)) { field in
                            field.smartDashesType = .no
                            field.smartQuotesType = .no
                            field.smartInsertDeleteType = .no
                        }
                        .focused($focus, equals: .text)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
        .font(.body)
        .animation(nil, value: shouldSecure)
        .onChange(of: shouldSecure) { newValue in
            focus = newValue ? .secure : .text
        }
    }

    public var secureButton: Button<Image> {
        Button {
            shouldSecure.toggle()
        } label: {
            shouldSecure ? Image(.eye) : Image(.eyeSlash)
        }
    }

    public var clearButton: Button<Image> {
        Button {
            input = ""
        } label: {
            Image.xmark
        }
    }
}

struct MEGAInputFieldSecure_Previews: PreviewProvider {
    static var previews: some View {
        MEGAInputField_Previews.previews
    }
}
