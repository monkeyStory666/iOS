// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension Text {
    /// Applies an underline to the text.
    ///
    /// This method underlines the text using the specified pattern and color.
    /// On iOS 16 and later, it uses the native `underline` method of `Text`.
    /// For earlier iOS versions, it falls back to a `border` method for underlining,
    /// which leads to the text being wrapped in a `Group`. This is because
    /// the earlier versions of iOS do not support underlining with custom patterns
    /// and colors directly on the `Text` view.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that determines whether the underline 
    ///   should be applied. The default value is `true`.
    ///   - pattern: The pattern of the underline line. This parameter is used
    ///   only in iOS 16 and later. In earlier versions, this parameter is ignored and
    ///   a single line is used.
    ///   - color: The color of the underline. In iOS versions earlier than 16,
    ///   this color is applied to the bottom border.
    ///
    /// - Returns: A view that conditionally applies an underline to the text.
    /// On iOS 16 and later, the returned type is `Text` with the specified underline
    /// style. On earlier versions, the text is wrapped in a `Group` with a border
    /// representing the underline.
    ///
    /// - Note: In earlier versions of iOS, the returned type is a generic `Group`
    /// view rather than a `Text` view, which can lead to a loss of `Text`-specific
    /// modifiers applied after this method. Additionally, the legacy version does not
    /// support multiline underlining, so texts spanning multiple lines will not be
    /// underlined as expected.
    @MainActor func underline(
        _ isActive: Bool = true,
        pattern: Text.LineStyle.Pattern,
        color: Color
    ) -> some View {
        return Group {
            if #available(iOS 16.0, *) {
                underline(
                    isActive,
                    pattern: pattern,
                    color: color
                )
            } else {
                if isActive {
                    border(
                        width: 1,
                        edges: [.bottom],
                        color: color
                    )
                } else {
                    self
                }
            }
        }
    }
}
