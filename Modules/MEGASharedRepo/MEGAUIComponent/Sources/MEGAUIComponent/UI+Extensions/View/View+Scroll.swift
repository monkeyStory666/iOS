import SwiftUI

public extension View {
    /// Detects if the view is scrolled near the top of a scroll view and triggers a callback.
    ///
    /// This modifier observes the vertical offset of the view within a named scroll view coordinate space
    /// and determines whether the view is considered "at the top", accounting for the provided top inset.
    /// When the view is within the specified threshold from the top (including the inset), it calls the
    /// `isAtTop` closure with `true`. Otherwise, it calls it with `false`.
    ///
    /// - Parameters:
    ///   - coordinateSpaceName: The name of the scroll view's coordinate space.
    ///   - topInset: An optional value representing the current safe area or content inset from the top.
    ///   - topOffsetThreshold: The maximum allowed distance from the top (after applying inset) to be considered "at the top".
    ///   - isAtTop: A closure that is called with `true` when the view is at the top, and `false` otherwise.
    ///
    /// - Returns: A modified view that detects its position relative to the top of a scroll view.
    ///
    /// ### Example
    /// ```swift
    /// @State private var isAtTop = false
    /// @State private var topInset: CGFloat = 0
    ///
    /// var body: some View {
    ///     ScrollView {
    ///         VStack {
    ///             Text("Target View")
    ///                 .frame(height: 50)
    ///                 .onScrollNearTop(
    ///                     coordinateSpaceName: "scroll",
    ///                     topInset: topInset,
    ///                     topOffsetThreshold: 10,
    ///                     isAtTop: { isAtTop = $0 }
    ///                 )
    ///             Color.red.frame(height: 500)
    ///         }
    ///     }
    ///     .coordinateSpace(name: "scroll")
    ///     .onTopInsetChange($topInset)
    /// }
    /// ```
    func onScrollNearTop(
        coordinateSpaceName: String,
        topInset: CGFloat,
        topOffsetThreshold: CGFloat,
        isAtTop: @escaping (Bool) -> Void
    ) -> some View {
        modifier(
            ScrollNearTop(
                coordinateSpaceName: coordinateSpaceName,
                topInset: topInset,
                topOffsetThreshold: topOffsetThreshold,
                isAtTop: isAtTop
            )
        )
    }
}

/// A view modifier that detects if a view is currently near the top of a scroll view.
private struct ScrollNearTop: ViewModifier {
    let coordinateSpaceName: String
    let topInset: CGFloat
    let topOffsetThreshold: CGFloat
    let isAtTop: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named(coordinateSpaceName)).minY
                    Color.clear
                        .onAppear {
                            updateIsAtTop(offset: offset, topInset: topInset)
                        }
                        .onChange(of: offset) { updatedOffset in
                            updateIsAtTop(offset: updatedOffset, topInset: topInset)
                        }
                        .onChange(of: topInset) { newValue in
                            updateIsAtTop(offset: offset, topInset: newValue)
                        }
                }
            }
    }

    private func updateIsAtTop(offset: CGFloat, topInset: CGFloat) {
        // True when the view is within the top threshold, accounting for inset
        isAtTop(offset + topInset > -topOffsetThreshold)
    }
}
