import SwiftUI

public extension View {
    /// Tracks the top safe area inset (like the height of the notch or status bar).
    ///
    /// - Parameter onChange: A closure that gets called when the top inset changes.
    /// - Returns: The view with top inset tracking applied.
    ///
    /// ### Example
    /// ```swift
    /// var body: some View {
    ///     Color.blue
    ///         .onTopInsetChange { inset in
    ///             print("Top inset changed: \(inset)")
    ///         }
    /// }
    /// ```
    func onTopInsetChange(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        modifier(TrackTopInset(onChange: onChange))
    }
}

/// Tracks the safe area top inset (for example, the notch on iPhones).
///
/// This is useful when you want to calculate your layout based on how much space is at the top.
private struct TrackTopInset: ViewModifier {
    let onChange: (CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            onChange(geo.safeAreaInsets.top)
                        }
                        .onChange(of: geo.safeAreaInsets.top, perform: onChange)
                }
            )
    }
}
