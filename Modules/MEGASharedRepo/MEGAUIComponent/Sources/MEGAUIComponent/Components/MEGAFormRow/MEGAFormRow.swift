// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

/// A structured form row with header, input field, and footer views.
///
/// This view allows the presentation of a typical form row with optional header and footer views,
/// based on whether the input field within the row is currently focused.
///
/// - Parameters:
///   - Header: The `View` type representing the header of the form row.
///   - InputField: The `View` type representing the main input field of the form row.
///   - Footer: The `View` type representing the footer of the form row.
///
/// Example Usage:
///
/// ```swift
/// MEGAFormRow { isFocused in
///     Text(isFocused ? "Is Focused Header" : "Not Focused Header")
/// } inputField: { _ in
///     MEGAInputField(clearableText: $customHeaderFooter)
/// } footer: { isFocused in
///     Text(isFocused ? "Is Focused Footer" : "Not Focused Footer")
/// }
/// ```
public struct MEGAFormRow<
    Header: View,
    InputField: View,
    Footer: View
>: View {
    @FocusState private var isFocused

    private let header: (IsFocused) -> Header
    private let inputField: (IsFocused) -> InputField
    private let footer: (IsFocused) -> Footer

    public init(
        @ViewBuilder header: @escaping (IsFocused) -> Header,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField,
        @ViewBuilder footer: @escaping (IsFocused) -> Footer
    ) {
        self.header = header
        self.inputField = inputField
        self.footer = footer
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header(isFocused)
            inputField(isFocused)
                .focused($isFocused)
            footer(isFocused)
        }
    }
}

struct MEGAFormRow_Previews: PreviewProvider {
    private enum FormField: String, Hashable, CaseIterable {
        case customHeaderFooter
        case titleOnly
        case titleAndFooter
        case footerOnly
    }

    struct Shim: View {
        @FocusState private var focusedField: FormField?

        @State private var customHeaderFooter = ""
        @State private var titleOnly = ""
        @State private var titleAndFooter = ""
        @State private var footerOnly = ""

        var body: some View {
            Group {
                MEGAFormRow { isFocused in
                    Text(isFocused ? "Is Focused Header" : "Not Focused Header")
                        .font(.caption2)
                        .foregroundStyle(isFocused ? Color.red : Color.primary)
                } inputField: { _ in
                    TextField("Custom Header and Footer", text: $customHeaderFooter)
                } footer: { isFocused in
                    Text(isFocused ? "Is Focused Footer" : "Not Focused Footer")
                        .font(.caption2)
                        .foregroundStyle(isFocused ? Color.red : Color.primary)
                }
                .focused($focusedField, equals: .customHeaderFooter)

                MEGAFormRow("Title Only") {
                    MEGAInputField(clearableText: $titleOnly)
                }
                .focused($focusedField, equals: .titleOnly)

                MEGAFormRow("Title and Footer") {
                    TextField("Title and Footer", text: $titleAndFooter)
                } footer: { _ in
                    Text("Custom Footer")
                        .font(.caption2)
                }
                .focused($focusedField, equals: .titleAndFooter)

                MEGAFormRow {
                    TextField("Footer Only", text: $footerOnly)
                } footer: { _ in
                    Text("Custom Footer")
                        .font(.caption2)
                }
                .focused($focusedField, equals: .footerOnly)
            }
            .submitLabel(.next)
            .onSubmit(of: .text) {
                switch focusedField {
                case .customHeaderFooter: focusedField = .titleOnly
                case .titleOnly: focusedField = .titleAndFooter
                case .titleAndFooter: focusedField = .footerOnly
                case .footerOnly: focusedField = nil
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
