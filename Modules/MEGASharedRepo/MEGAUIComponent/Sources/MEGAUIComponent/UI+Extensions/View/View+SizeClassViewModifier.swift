// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public typealias IsSizeClassIncluded = (UserInterfaceSizeClass) -> Bool

/// A `ViewModifier` for SwiftUI views that enables conditional modifications based on the current device's size class.
///
/// This modifier allows developers to apply custom view modifications based on the horizontal and vertical size classes of the user interface. It is particularly useful for creating adaptive layouts in SwiftUI, allowing the UI to adjust gracefully to various screen sizes and orientations.
///
/// Usage:
/// Attach this modifier to any SwiftUI view to conditionally apply modifications based on size classes.
///
public struct SizeClassViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @Environment(\.verticalSizeClass)
    private var verticalSizeClass

    public var isHorizontalIncluded: IsSizeClassIncluded = { _ in false }
    public var isVerticalIncluded: IsSizeClassIncluded = { _ in false }

    @ViewBuilder var builder: (Content) -> AnyView

    public init(
        isHorizontalIncluded: @escaping IsSizeClassIncluded = { _ in false },
        isVerticalIncluded: @escaping IsSizeClassIncluded = { _ in false },
        builder: @escaping (Content) -> some View
    ) {
        self.isHorizontalIncluded = isHorizontalIncluded
        self.isVerticalIncluded = isVerticalIncluded
        self.builder = { AnyView(builder($0)) }
    }

    var shouldBeModified: Bool {
        isVerticalSizeClassIncluded || isHorizontalSizeClassIncluded
    }

    var isVerticalSizeClassIncluded: Bool {
        guard let verticalSizeClass else { return false }

        return isVerticalIncluded(verticalSizeClass)
    }

    var isHorizontalSizeClassIncluded: Bool {
        guard let horizontalSizeClass else { return false }

        return isHorizontalIncluded(horizontalSizeClass)
    }

    public func body(content: Content) -> some View {
        if shouldBeModified {
            builder(content)
        } else {
            content
        }
    }
}

public extension SizeClassViewModifier {
    init(
        horizontalSizeClass: UserInterfaceSizeClass? = nil,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        builder: @escaping (Content) -> some View
    ) {
        self.isHorizontalIncluded = {
            if let horizontalSizeClass {
                return $0 == horizontalSizeClass
            } else {
                return false
            }
        }
        self.isVerticalIncluded = {
            if let verticalSizeClass {
                return $0 == verticalSizeClass
            } else {
                return false
            }
        }
        self.builder = { AnyView(builder($0)) }
    }
}

public extension View {
    /// Modifies the view based on custom conditions for horizontal and vertical size classes.
    ///
    /// - Parameters:
    ///   - isHorizontalIncluded: A closure defining the condition for including the horizontal size class.
    ///   - isVerticalIncluded: A closure defining the condition for including the vertical size class.
    ///   - builder: A closure that takes the content view and returns a modified view.
    ///
    /// **Example Usage:**
    ///
    /// Compact Horizontal and Regular Vertical Size Class:
    /// ```
    /// Text("Compact Horizontal and Regular Vertical")
    ///     .modifySizeClass(
    ///         isHorizontalIncluded: { $0 == .compact },
    ///         isVerticalIncluded: { $0 == .regular }
    ///     ) { content in
    ///         content.padding()
    ///     }
    /// ```
    ///
    /// Regular Horizontal Size Class:
    /// ```
    /// Text("Regular Horizontal")
    ///     .modifySizeClass(
    ///         isHorizontalIncluded: { $0 == .compact }
    ///     ) { content in
    ///         content.padding()
    ///     }
    /// ```
    func modifySizeClass(
        isHorizontalIncluded: @escaping IsSizeClassIncluded = { _ in false },
        isVerticalIncluded: @escaping IsSizeClassIncluded = { _ in false },
        builder: @escaping (SizeClassViewModifier.Content) -> some View
    ) -> some View {
        modifier(
            SizeClassViewModifier(
                isHorizontalIncluded: isHorizontalIncluded,
                isVerticalIncluded: isVerticalIncluded,
                builder: builder
            )
        )
    }

    /// Modifies the view based on specific horizontal and vertical size classes.
    ///
    /// - Parameters:
    ///   - horizontalSizeClass: The specific horizontal size class to check for. If `nil`, the horizontal size class condition is ignored.
    ///   - verticalSizeClass: The specific vertical size class to check for. If `nil`, the vertical size class condition is ignored.
    ///   - builder: A closure that takes the content view and returns a modified view.
    ///
    /// **Example Usage:**
    ///
    /// Compact Horizontal and Regular Vertical Size Class:
    /// ```
    /// Text("Compact Horizontal and Regular Vertical")
    ///     .modifySizeClass(
    ///         horizontalSizeClass: .compact,
    ///         verticalSizeClass: .regular
    ///     ) { content in
    ///         content.padding()
    ///     }
    /// ```
    ///
    /// Regular Horizontal Size Class:
    /// ```
    /// Text("Regular Horizontal")
    ///     .modifySizeClass(horizontalSizeClass: .regular) { content in
    ///         content.padding()
    ///     }
    /// ```
    func modifySizeClass(
        horizontalSizeClass: UserInterfaceSizeClass? = nil,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        builder: @escaping (SizeClassViewModifier.Content) -> some View
    ) -> some View {
        modifier(
            SizeClassViewModifier(
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass,
                builder: builder
            )
        )
    }
}
