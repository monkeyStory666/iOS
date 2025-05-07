// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct ViewPaddingEntity {
    public var edges: Edge.Set
    public var amount: CGFloat

    public init(edges: Edge.Set, amount: CGFloat) {
        self.edges = edges
        self.amount = amount
    }
}

public extension View {
    func padding(_ entities: [ViewPaddingEntity]) -> some View {
        modifier(PaddingViewModifier(paddings: entities))
    }
}

public struct PaddingViewModifier: ViewModifier {
    public var paddings: [ViewPaddingEntity]

    @ViewBuilder
    public func body(content: Content) -> some View {
        if let firstPadding = paddings.first {
            content
                .padding(firstPadding.edges, firstPadding.amount)
                .modifier(PaddingViewModifier(paddings: Array(paddings.dropFirst())))
        } else {
            content
        }
    }
}

public extension Array where Element == ViewPaddingEntity {
    static var zero: [ViewPaddingEntity] {
        [ViewPaddingEntity(edges: .all, amount: 0)]
    }
}
