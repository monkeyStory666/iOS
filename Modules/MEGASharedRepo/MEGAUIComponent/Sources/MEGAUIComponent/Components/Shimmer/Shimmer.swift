// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

/// A view modifier that applies an animated "shimmer" to any view, typically to show that an operation is in progress.
public struct Shimmer: ViewModifier {
    private let min, max: CGFloat

    @State private var isInitialState = true

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.layoutDirection)
    private var layoutDirection

    /// Initializes his modifier with a custom animation,
    /// - Parameters:
    ///  - bandSize: The size of the animated mask's "band". Defaults to 0.5 unit points, which corresponds to
    /// 50% of the extent of the gradient.
    public init(bandSize: CGFloat = 0.5) {
        self.min = 0 - bandSize
        self.max = 1 + bandSize
    }

    public var animation: Animation {
        .linear(duration: 1.5)
            .delay(0.25)
            .repeatForever(autoreverses: false)
    }

    public var gradient: Gradient {
        if colorScheme == .dark {
            return Gradient(colors: [
                .black.opacity(0.2),
                .black.opacity(0.35),
                .black.opacity(0.2)
            ])
        } else {
            return Gradient(colors: [
                .black.opacity(0.8),
                .black.opacity(0.6),
                .black.opacity(0.8)
            ])
        }
    }

    private var startPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            return isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        } else {
            return isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        }
    }

    private var endPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            return isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        } else {
            return isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        }
    }

    public func body(content: Content) -> some View {
        content
            .mask(LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint))
            .animation(animation, value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that an operation is in progress.
    /// - Parameters:
    ///  - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///  - bandSize: The size of the animated mask's "band". Defaults to 0.5 unit points, which corresponds to
    /// 50% of the extent of the gradient.
    @ViewBuilder
    func shimmering(
        active: Bool = true,
        bandSize: CGFloat = 0.5,
        redactedReason: RedactionReasons? = .placeholder
    ) -> some View {
        if let redactedReason, active {
            foregroundStyle(TokenColors.Background.inverse.swiftUI)
                .redacted(reason: redactedReason)
                .modifier(Shimmer(bandSize: bandSize))
        } else if active {
            foregroundStyle(TokenColors.Background.inverse.swiftUI)
                .modifier(Shimmer(bandSize: bandSize))
        } else {
            self
        }
    }
}
