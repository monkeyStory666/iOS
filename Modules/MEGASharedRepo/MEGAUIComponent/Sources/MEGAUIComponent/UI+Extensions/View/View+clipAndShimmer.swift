// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {
    /// Applies a specified shape to clip the view and adds a shimmering effect.
    ///
    /// This function wraps the content of the view in a `ClipAndShimmerModifier`
    /// that clips the view to the specified shape and then applies a shimmering effect.
    /// By default, it uses a `RoundedRectangle` with a corner radius of 10 as the clipping shape.
    ///
    /// - Parameter shape: The shape to clip the view. Defaults to `RoundedRectangle(cornerRadius:
    /// 10)`.
    /// - Returns: A view modified with a clip shape and shimmering effect.
    func clipAndShimmer(
        using shape: some Shape = RoundedRectangle(cornerRadius: 10)
    ) -> some View {
        modifier(ClipAndShimmerModifier(shimmerShape: shape))
    }
}

struct ClipAndShimmerModifier<ShimmerShape: Shape>: ViewModifier {
    let shimmerShape: ShimmerShape

    func body(content: Content) -> some View {
        content
            .clipShape(shimmerShape)
            .shimmering()
    }
}
