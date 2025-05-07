// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAList<
    ContentView: View,
    LeadingView: View,
    TrailingView: View,
    HeaderView: View,
    FooterView: View
>: View {
    public var contentView: () -> ContentView

    public var leadingView: () -> LeadingView
    public var trailingView: () -> TrailingView

    public var headerView: () -> HeaderView
    public var footerView: () -> FooterView

    public var contentBorderEdges: Edge.Set = []

    public var padding: [MEGAListPaddedSection: [ViewPaddingEntity]] = [:]

    public init(
        contentBorderEdges: Edge.Set = [],
        padding: [MEGAListPaddedSection: [ViewPaddingEntity]] = .megaListDefaultPadding,
        @ViewBuilder contentView: @escaping () -> ContentView,
        @ViewBuilder headerView: @escaping () -> HeaderView = { EmptyView() },
        @ViewBuilder footerView: @escaping () -> FooterView = { EmptyView() },
        @ViewBuilder leadingView: @escaping () -> LeadingView = { EmptyView() },
        @ViewBuilder trailingView: @escaping () -> TrailingView = { EmptyView() }
    ) {
        self.contentBorderEdges = contentBorderEdges
        self.padding = padding
        self.contentView = contentView
        self.headerView = headerView
        self.footerView = footerView
        self.leadingView = leadingView
        self.trailingView = trailingView
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView()
                .padding(padding[.header] ?? [])
            HStack(spacing: TokenSpacing._5) {
                leadingView()
                VStack(spacing: 0) {
                    contentView()
                }
                trailingView()
            }
            .padding(padding[.content] ?? [])
            .frame(maxWidth: .infinity)
            .border(
                width: 0.33,
                edges: contentBorderEdges,
                color: TokenColors.Border.subtle.swiftUI
            )
            footerView()
                .padding(padding[.footer] ?? [])
        }
    }
}
