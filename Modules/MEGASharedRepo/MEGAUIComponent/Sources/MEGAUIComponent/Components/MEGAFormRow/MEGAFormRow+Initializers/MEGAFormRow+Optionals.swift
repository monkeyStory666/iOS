// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

/// Extensions providing initializers for `MEGAFormRow` without a header.
public extension MEGAFormRow where Header == EmptyView {
    /// Creates a new instance without a header and using `IsFocused` for the input field and
    /// footer.
    init(
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField,
        @ViewBuilder footer: @escaping (IsFocused) -> Footer
    ) {
        self.init(
            header: { _ in EmptyView() },
            inputField: inputField,
            footer: footer
        )
    }

    /// Creates a new instance without a header and using `IsFocused` for the footer.
    init(
        @ViewBuilder inputField: @escaping () -> InputField,
        @ViewBuilder footer: @escaping (IsFocused) -> Footer
    ) {
        self.init(
            inputField: { _ in
                inputField()
            },
            footer: footer
        )
    }

    /// Creates a new instance without a header and using `IsFocused` for the input field.
    init(
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            inputField: inputField,
            footer: { _ in
                footer()
            }
        )
    }

    /// Creates a new instance without a header.
    init(
        @ViewBuilder inputField: @escaping () -> InputField,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            inputField: { _ in
                inputField()
            },
            footer: { _ in
                footer()
            }
        )
    }
}

/// Extensions providing initializers for `MEGAFormRow` without a footer.
public extension MEGAFormRow where Footer == EmptyView {
    /// Creates a new instance without a footer and using `IsFocused` for the header and input
    /// field.
    init(
        @ViewBuilder header: @escaping (IsFocused) -> Header,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField
    ) {
        self.init(
            header: header,
            inputField: inputField,
            footer: { _ in EmptyView() }
        )
    }

    /// Creates a new instance without a footer and using `IsFocused` for the header.
    init(
        @ViewBuilder header: @escaping (IsFocused) -> Header,
        @ViewBuilder inputField: @escaping () -> InputField
    ) {
        self.init(
            header: header,
            inputField: { _ in
                inputField()
            }
        )
    }

    /// Creates a new instance without a footer and using `IsFocused` for the input field.
    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder inputField: @escaping (IsFocused) -> InputField
    ) {
        self.init(
            header: { _ in
                header()
            },
            inputField: inputField
        )
    }

    /// Creates a new instance without a footer.
    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder inputField: @escaping () -> InputField
    ) {
        self.init(
            header: { _ in
                header()
            },
            inputField: { _ in
                inputField()
            }
        )
    }
}

struct MEGAFormRowOptionals_Previews: PreviewProvider {
    static var previews: some View {
        MEGAFormRow_Previews.previews
    }
}
