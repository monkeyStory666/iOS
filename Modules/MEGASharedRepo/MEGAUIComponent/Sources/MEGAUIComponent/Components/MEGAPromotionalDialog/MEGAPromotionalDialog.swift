// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAPromotionalDialog<
    HeaderView: View,
    ContentView: View,
    FooterView: View,
    ToolbarView: View
>: View {
    public var headerView: () -> HeaderView
    public var contentView: () -> ContentView
    public var footerView: () -> FooterView
    public var toolbarView: () -> ToolbarView

    public var headlineText: AttributedString
    public var smallTitleText: AttributedString?
    public var bodyText: AttributedString?

    public var textAlignment: TextAlignment

    public var ignoreSafeAreaEdges: Edge.Set = []
    public var hasCloseButtonOverlay = false

    public var dismissAction: (() -> Void)?

    public init(
        headerView: @escaping () -> HeaderView,
        headlineText: String,
        smallTitleText: String? = nil,
        bodyText: String? = nil,
        textAlignment: TextAlignment = .center,
        ignoreSafeAreaEdges: Edge.Set = [],
        hasCloseButtonOverlay: Bool = false,
        contentView: @escaping () -> ContentView = { EmptyView() },
        footerView: @escaping () -> FooterView = { EmptyView() },
        toolbarView: @escaping () -> ToolbarView = { EmptyView() },
        dismissAction: (() -> Void)? = nil
    ) {
        self.headerView = headerView
        self.contentView = contentView
        self.footerView = footerView
        self.headlineText = AttributedString(headlineText)
        self.smallTitleText = smallTitleText.map(AttributedString.init)
        self.bodyText = bodyText.map(AttributedString.init)
        self.textAlignment = textAlignment
        self.ignoreSafeAreaEdges = ignoreSafeAreaEdges
        self.hasCloseButtonOverlay = hasCloseButtonOverlay
        self.toolbarView = toolbarView
        self.dismissAction = dismissAction
    }

    public init(
        headerView: @escaping () -> HeaderView,
        headlineText: AttributedString,
        smallTitleText: AttributedString? = nil,
        bodyText: AttributedString? = nil,
        textAlignment: TextAlignment = .center,
        ignoreSafeAreaEdges: Edge.Set = [],
        hasCloseButtonOverlay: Bool = false,
        contentView: @escaping () -> ContentView = { EmptyView() },
        footerView: @escaping () -> FooterView = { EmptyView() },
        toolbarView: @escaping () -> ToolbarView = { EmptyView() },
        dismissAction: (() -> Void)? = nil
    ) {
        self.headerView = headerView
        self.contentView = contentView
        self.footerView = footerView
        self.headlineText = headlineText
        self.smallTitleText = smallTitleText
        self.bodyText = bodyText
        self.textAlignment = textAlignment
        self.ignoreSafeAreaEdges = ignoreSafeAreaEdges
        self.hasCloseButtonOverlay = hasCloseButtonOverlay
        self.toolbarView = toolbarView
        self.dismissAction = dismissAction
    }

    public var body: some View {
        if #available(iOS 16, *) {
            // swiftlint:disable:next discouraged_navigationstack_usage
            NavigationStack {
                contentAndCloseButton
            }
        } else {
            // swiftlint:disable:next discouraged_navigationview_usage
            NavigationView {
                contentAndCloseButton
            }
            .navigationViewStyle(.stack)
        }
    }

    @ViewBuilder
    private var contentAndCloseButton: some View {
        if let dismissAction {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        closeButton(dismissAction)
                    }
                }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            scrollableBody
            bottomToolbar
        }
        .pageBackground()
    }

    private var scrollableBody: some View {
        DynamicScrollView {
            VStack(spacing: 0) {
                headerView()
                mainContent
                footerView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.container, edges: ignoreSafeAreaEdges)
    }

    private var mainContent: some View {
        VStack(spacing: TokenSpacing._5) {
            Group {
                VStack(spacing: TokenSpacing._3) {
                    if let smallTitleText {
                        Text(smallTitleText)
                            .font(.headline)
                            .multilineTextAlignment(textAlignment)
                            .foregroundStyle(TokenColors.Button.brand.swiftUI)
                    }
                    Text(headlineText)
                        .font(.title.bold())
                        .multilineTextAlignment(textAlignment)
                        .foregroundStyle(TokenColors.Text.primary.swiftUI)
                }
                if let bodyText {
                    Text(bodyText)
                        .font(.subheadline)
                        .multilineTextAlignment(textAlignment)
                        .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                }
            }
            .multilineTextAlignment(textAlignment)
            .padding(.horizontal, TokenSpacing._5)
            .frame(maxWidth: .infinity)
            contentView()
        }
        .padding(.vertical, TokenSpacing._9)
    }

    private var bottomToolbar: some View {
        toolbarView()
            .border(
                width: 1, edges: .top,
                color: TokenColors.Border.subtle.swiftUI
            )
            .padding(.bottom, TokenSpacing._5)
    }

    @ViewBuilder
    private func closeButton(_ dismissAction: @escaping () -> Void) -> some View {
        Button(action: dismissAction) {
            if hasCloseButtonOverlay {
                closeButtonIcon
                    .foregroundStyle(TokenColors.Icon.onColor.swiftUI)
                    .padding(TokenSpacing._1)
                    .background(
                        Circle().fill(TokenColors.Background.blur.swiftUI)
                    )
            } else {
                closeButtonIcon
                    .foregroundStyle(TokenColors.Icon.primary.swiftUI)
            }
        }
    }

    private var closeButtonIcon: some View {
        Image("XMediumLightOutline", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}
