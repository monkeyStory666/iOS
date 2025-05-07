// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

@available(*, deprecated, renamed: "MEGAList", message: "ListRowView is deprecated, please use MEGAList type")
public struct ListRowView<
    LeadingView: View,
    TrailingView: View
>: View {
    public var title: String
    public var subtitle: String?
    public var footer: String?

    public var titleRedactionText: String?
    public var subtitleRedactionText: String?

    public var primaryColor: Color
    public var secondaryColor: Color

    public var showBorder: Bool

    public var leadingView: () -> LeadingView
    public var trailingView: () -> TrailingView

    public init(
        title: String,
        subtitle: String? = nil,
        footer: String? = nil,
        titleRedactionText: String? = nil,
        subtitleRedactionText: String? = nil,
        primaryColor: Color = TokenColors.Text.primary.swiftUI,
        secondaryColor: Color = TokenColors.Text.secondary.swiftUI,
        showBorder: Bool = true,
        @ViewBuilder leadingView: @escaping () -> LeadingView = { EmptyView() },
        @ViewBuilder trailingView: @escaping () -> TrailingView = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.footer = footer
        self.titleRedactionText = titleRedactionText
        self.subtitleRedactionText = subtitleRedactionText
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.showBorder = showBorder
        self.leadingView = leadingView
        self.trailingView = trailingView
    }

    public var body: some View {
        if let footer, !footer.isEmpty {
            VStack(alignment: .leading) {
                content
                Text(footer)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(secondaryColor)
                    .padding(.horizontal, TokenSpacing._5)
            }
        } else {
            content
        }
    }

    @ViewBuilder var content: some View {
        if showBorder {
            innerContent
                .border(width: 0.33, edges: [.top, .bottom], color: TokenColors.Border.subtle.swiftUI)
                .contentShape(Rectangle())
        } else {
            innerContent
                .contentShape(Rectangle())
        }
    }

    var innerContent: some View {
        HStack(alignment: .center, spacing: TokenSpacing._4) {
            leadingView()
            contentLabel
            Spacer()
            trailingView()
        }
        .padding(.horizontal, TokenSpacing._5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var contentLabel: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._2) {
            Group {
                Text(titleRedactionText ?? title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(primaryColor)
                    .shimmering(active: titleRedactionText != nil)
                if let subtitle {
                    Text(subtitleRedactionText ?? subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(secondaryColor)
                        .shimmering(active: subtitleRedactionText != nil)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .frame(minHeight: 60)
    }
}
