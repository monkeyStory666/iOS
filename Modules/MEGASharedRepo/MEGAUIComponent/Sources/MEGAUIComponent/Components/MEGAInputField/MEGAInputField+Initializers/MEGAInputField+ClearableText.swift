// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

/// Extensions providing initializers for `MEGAInputField` with clearable functionality.
public extension MEGAInputField where Accessory == Button<Image>? {
    /// Creates a clearable input field with customizable appearance.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///   - viewModifiers: A closure that modifies the appearance and behavior of the input field.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Clearable Input Field") {
    ///     MEGAInputField(clearableText: $clearable) { textField, isFocused in
    ///         textField.foregroundColor(isFocused ? .red : .blue)
    ///     }
    /// }
    /// ```
    init(
        clearableText input: Binding<String>,
        @ViewBuilder fieldAppearance viewModifiers: @escaping (TextField<EmptyView>, IsFocused)
            -> Field
    ) {
        self.init { isFocused in
            viewModifiers(TextField(input), isFocused)
        } accessoryBuilder: { isFocused in
            #if targetEnvironment(macCatalyst)
            return nil
            #else
            if !input.wrappedValue.isEmpty && isFocused {
                Button {
                    if !input.wrappedValue.isEmpty {
                        input.wrappedValue = ""
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
            #endif
        }
    }

    /// Creates a clearable input field without the need for view modifiers based on focus.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///   - viewModifiers: A closure that modifies the appearance and behavior of the input field.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Clearable Input Field") {
    ///     MEGAInputField(clearableText: $clearable) { textField in
    ///         textField.foregroundColor(.blue)
    ///     }
    /// }
    /// ```
    init(
        clearableText input: Binding<String>,
        @ViewBuilder fieldAppearance viewModifiers: @escaping (TextField<EmptyView>) -> Field
    ) {
        self.init(
            clearableText: input,
            fieldAppearance: { textField, _ in
                viewModifiers(textField)
            }
        )
    }
}

/// Extensions providing initializers for `MEGAInputField` with clearable functionality.
public extension MEGAInputField where Field == TextField<EmptyView>, Accessory == Button<Image>? {
    /// Creates a clearable input field with default appearance.
    ///
    /// - Parameters:
    ///   - input: A binding to the underlying text of the input field.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Clearable Input Field") {
    ///     MEGAInputField(clearableText: $clearable)
    /// }
    /// ```
    init(clearableText input: Binding<String>) {
        self.init(
            clearableText: input,
            fieldAppearance: { textField, _ in
                textField
            }
        )
    }
}

struct MEGAInputFieldClearable_Previews: PreviewProvider {
    static var previews: some View {
        MEGAInputField_Previews.previews
    }
}
