// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension View {
    /// Applies a full-page background color with customizable alignment.
    ///
    /// This function is created to address layout issues on iPad, where using `.background(Color)`
    /// without `frame(maxWidth:maxHeight:)` often results in backgrounds that do not extend to the
    /// full size of the view. `pageBackground` ensures the background color covers the entire view.
    ///
    /// Using this function is recommended over manually setting a background color to prevent
    /// layout inconsistencies, especially on larger screens.
    ///
    /// - Parameters:
    ///   - alignment: The alignment of the content within the page. Defaults to `.center`. Useful for
    ///     specific alignment needs.
    ///   - backgroundColor: The color for the background. Defaults to the standard page background
    ///     color.
    ///
    /// - Returns: A modified view that extends the background color to the full width and height of the page.
    ///
    /// Example Usage:
    /// ```
    /// Text("Hello, World!")
    ///     .pageBackground() // Default usage with full coverage and centered content
    ///
    /// Text("Welcome")
    ///     .pageBackground(alignment: .top, backgroundColor: .green) // Custom alignment and color
    /// ```
    func pageBackground(
        alignment: Alignment = .center,
        backgroundColor: Color = TokenColors.Background.page.swiftUI
    ) -> some View {
        frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: alignment
        )
        .background(backgroundColor)
    }
}

