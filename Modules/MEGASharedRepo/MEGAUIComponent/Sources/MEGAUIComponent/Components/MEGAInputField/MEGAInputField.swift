// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public typealias IsFocused = Bool

/// A structured input field with optional accessory view.
///
/// This view presents an input field alongside an optional accessory view. It also provides
/// customization for border color based on the focused state of the field.
///
/// - Parameters:
///   - Field: The `View` type representing the main input field.
///   - Accessory: The `View` type representing the optional accessory view.
///
/// Example Usage:
///
/// ```swift
/// MEGAFormRow("Clearable Input Field") {
///     MEGAInputField(clearableText: $clearable)
/// }
///
/// MEGAFormRow("Custom Color On Focus") { isFocused in
///     MEGAInputField(clearableText: $customColorOnFocus)
///         .borderColor(isFocused ? .red : nil)
/// }
/// ```
public struct MEGAInputField<
    Field: View,
    Accessory: View
>: View {
    @FocusState private var isFocused

    private let field: (IsFocused) -> Field
    private let accessoryBuilder: (IsFocused) -> Accessory

    public var customBorderColor: Color?
    private var borderColor: Color {
        if let customBorderColor {
            customBorderColor
        } else {
            isFocused
                ? TokenColors.Border.strongSelected.swiftUI
                : TokenColors.Border.strong.swiftUI
        }
    }

    public init(
        @ViewBuilder field: @escaping (IsFocused) -> Field,
        @ViewBuilder accessoryBuilder: @escaping (IsFocused) -> Accessory
    ) {
        self.field = field
        self.accessoryBuilder = accessoryBuilder
    }

    public var body: some View {
        HStack(spacing: 16) {
            field(isFocused)
                .focused($isFocused)
                .foregroundColor(TokenColors.Icon.primary.swiftUI)
            accessoryBuilder(isFocused)
                .foregroundColor(TokenColors.Icon.primary.swiftUI)
        }
        .font(.body)
        .padding(.init(top: 12, leading: 14, bottom: 12, trailing: 14))
        .frame(minHeight: 49)
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .strokeBorder(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - No Accessory

public extension MEGAInputField where Accessory == EmptyView {
    init(@ViewBuilder field: @escaping (IsFocused) -> Field) {
        self.init(field: field, accessoryBuilder: { _ in EmptyView() })
    }
}

// MARK: - Preview

struct MEGAInputField_Previews: PreviewProvider {
    private enum FormField: Hashable {
        case clearable
        case modifiedClearable
        case secure
        case customColorOnFocus
    }

    private struct Shim: View {
        @FocusState private var focusedField: FormField?

        @State private var clearable = ""
        @State private var modifiedClearable = ""
        @State private var secure = ""
        @State private var shouldSecure = true
        @State private var customColorOnFocus = ""

        var body: some View {
            Group {
                MEGAFormRow("Clearable Input Field") {
                    MEGAInputField(clearableText: $clearable)
                }
                .focused($focusedField, equals: .clearable)

                MEGAFormRow("Modified Input Field") {
                    MEGAInputField(clearableText: $modifiedClearable) { inputField in
                        inputField
                            .textContentType(.countryName)
                            .font(.largeTitle)
                            .foregroundStyle(Color.red)
                    }
                }
                .focused($focusedField, equals: .modifiedClearable)

                MEGAFormRow("Secure Field") {
                    MEGAInputField(
                        shouldSecure: $shouldSecure,
                        protectedText: $secure
                    )
                }
                .focused($focusedField, equals: .secure)

                MEGAFormRow("Custom Color On Focus") { isFocused in
                    MEGAInputField(clearableText: $customColorOnFocus)
                        .borderColor(isFocused ? .red : nil)
                }
                .focused($focusedField, equals: .customColorOnFocus)
            }
            .submitLabel(.next)
            .onSubmit(of: .text) {
                switch focusedField {
                case .clearable: focusedField = .modifiedClearable
                case .modifiedClearable: focusedField = .secure
                case .secure: focusedField = .customColorOnFocus
                case .customColorOnFocus: focusedField = nil
                default: focusedField = nil
                }
            }
        }
    }

    static var previews: some View {
        Form {
            Shim()
        }
    }
}
