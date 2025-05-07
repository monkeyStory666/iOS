// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

/// A view modifier that sets a fixed maximum width for the view based on the horizontal size class.
///
/// Example:
///
///     struct ContentView: View {
///         var body: some View {
///             Text("Hello, World!")
///                 .modifier(FixedWidthForRegularSizeClassModifier(maxWidth: 300))
///         }
///     }
public struct FixedWidthForRegularSizeClassModifier: ViewModifier {
    /// The horizontal size class environment value.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    /// The maximum width to be applied when the horizontal size class is `.regular`.
    let maxWidth: CGFloat?

    public init(maxWidth: CGFloat?) {
        self.maxWidth = maxWidth
    }

    public func body(content: Content) -> some View {
        let width: CGFloat? = horizontalSizeClass == .regular ? maxWidth : nil
        return content.frame(maxWidth: width)
    }
}

public extension View {
    private var wideScreenMaxWidth: CGFloat { 500 }

    /// Applies a maximum width constraint to the view for wide screens (horizontal regular size class).
    ///
    /// This method is a convenience wrapper for modifying the view specifically for wide screen scenarios.
    /// It sets a maximum width of 390, determined by the UX team, only when the horizontal size class is regular.
    /// This is particularly useful for optimizing layouts on larger screens, such as iPads, where controlling the width of elements
    /// can lead to a more aesthetically pleasing and functional UI.
    ///
    /// Usage:
    /// Attach this method to any SwiftUI view to constrain its maximum width in a wide screen environment.
    ///
    func maxWidthForWideScreen() -> some View {
        self.modifier(FixedWidthForRegularSizeClassModifier(maxWidth: wideScreenMaxWidth))
    }
}
