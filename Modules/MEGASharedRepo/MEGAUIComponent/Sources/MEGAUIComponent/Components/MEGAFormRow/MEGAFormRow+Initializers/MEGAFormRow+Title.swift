// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

private func titleLabel(_ title: String) -> Text {
    Text(title)
        .font(.subheadline.bold())
        .foregroundColor(TokenColors.Text.primary.swiftUI)
}

/// Extensions providing initializers for `MEGAFormRow` using a text title as a header.
public extension MEGAFormRow where Header == Text {
    /// Creates a new instance with a text title as header, and using `IsFocused` for the input
    /// field and footer.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField,
        @ViewBuilder footer: @escaping (IsFocused) -> Footer
    ) {
        self.init(
            header: { _ in titleLabel(title) },
            inputField: inputField,
            footer: footer
        )
    }

    /// Creates a new instance with a text title as header, and using `IsFocused` for the footer.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping () -> InputField,
        @ViewBuilder footer: @escaping (IsFocused) -> Footer
    ) {
        self.init(
            title,
            inputField: { _ in
                inputField()
            },
            footer: footer
        )
    }

    /// Creates a new instance with a text title as header, and using `IsFocused` for the input
    /// field.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            title,
            inputField: inputField,
            footer: { _ in
                footer()
            }
        )
    }

    /// Creates a new instance with a text title as header.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping () -> InputField,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            title,
            inputField: { _ in
                inputField()
            },
            footer: { _ in
                footer()
            }
        )
    }
}

/// Extensions providing initializers for `MEGAFormRow` using a text title as a header without any
/// footer.
public extension MEGAFormRow where Header == Text, Footer == EmptyView {
    /// Creates a new instance with a text title as header without footer and using `IsFocused` for
    /// the input field.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField
    ) {
        self.init(
            title,
            inputField: inputField,
            footer: { _ in EmptyView() }
        )
    }

    /// Creates a new instance with a text title as header without footer.
    init(
        _ title: String,
        @ViewBuilder inputField: @escaping () -> InputField
    ) {
        self.init(
            title,
            inputField: { _ in
                inputField()
            }
        )
    }
}

struct MEGAFormRowTitle_Previews: PreviewProvider {
    static var previews: some View {
        MEGAFormRow_Previews.previews
    }
}
