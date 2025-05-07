// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

/// A view modifier that limits the number of characters entered into a `TextField`.
/// It monitors changes to the bound `text` property and truncates the text if it exceeds the specified limit.
struct CharacterLimitModifier: ViewModifier {
    /// The text bound to the `TextField`.
    @Binding var text: String

    /// The maximum number of characters allowed.
    /// If `nil`, no character limit is enforced.
    let limit: Int?

    /// A boolean value that determines whether to show the character counter.
    var showCounter = false

    func body(content: Content) -> some View {
        field(content: content)
            .onChange(of: text) { newValue in
                if let limit, newValue.count > limit {
                    text = String(newValue.prefix(limit))
                }
            }
    }

    @ViewBuilder func field(content: Content) -> some View {
        if let limit, showCounter {
            VStack(alignment: .trailing, spacing: TokenSpacing._2) {
                content
                Text("\(text.count)/\(limit)")
                    .font(.footnote)
                    .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                    .animation(nil, value: text.count)
            }
        } else {
            content
        }
    }
}

public extension TextField {
    /// Adds a character limit to a `TextField`.
    ///
    /// - Parameters:
    ///   - text: A binding to the `TextField`'s text value.
    ///   - limit: The maximum number of characters allowed in the `TextField`. If `nil`, no limit is enforced.
    /// - Returns: A `TextField` view with the character limit applied.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Clearable Input Field") {
    ///     MEGAInputField(clearableText: $clearable) { textField in
    ///         textField
    ///             .maxCharacterLimit($clearable, to: 40)
    ///     }
    /// }
    /// ```
    func maxCharacterLimit(
        _ text: Binding<String>,
        to limit: Int?
    ) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit))
    }
}

public extension MEGAInputField {
    /// Adds a character limit to a `MEGAInputField`.
    ///
    /// - Parameters:
    ///   - text: A binding to the `MEGAInputField`'s text value.
    ///   - limit: The maximum number of characters allowed in the `MEGAInputField`. If `nil`, no limit is enforced.
    ///   - showCounter: A boolean value that determines whether to show the character counter.
    /// - Returns: A `MEGAInputField` view with the character limit applied.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAFormRow("Clearable Input Field") {
    ///     MEGAInputField(clearableText: $clearable)
    ///         .maxCharacterLimit($clearable, to: 40, showCounter: true)
    /// }
    /// ```
    func maxCharacterLimit(
        _ text: Binding<String>,
        to limit: Int?,
        showCounter: Bool = false
    ) -> some View {
        modifier(CharacterLimitModifier(text: text, limit: limit, showCounter: showCounter))
    }
}
