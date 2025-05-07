// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension MEGAPromotionalDialog {
    // MARK: - With Old Content View Parameter

    /// Updates the `contentView` of the `MEGAPromotionalDialog` with a new type, using the old `contentView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `ContentView` into a new `NewContentView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `contentView`.
    ///
    /// Example Usage:
    /// ```swift
    /// updatedContentView {
    ///     $0.property = newProperty
    ///     return $0
    /// }
    /// ```
    func updatedContentView<NewContentView: View>(
        _ transform: @escaping (inout ContentView) -> NewContentView
    ) -> UpdatedContentView<NewContentView> {
        .init(
            headerView: headerView,
            headlineText: headlineText,
            smallTitleText: smallTitleText,
            bodyText: bodyText,
            textAlignment: textAlignment,
            ignoreSafeAreaEdges: ignoreSafeAreaEdges,
            hasCloseButtonOverlay: hasCloseButtonOverlay,
            contentView: {
                var newContentView = self.contentView()
                return transform(&newContentView)
            },
            footerView: footerView,
            toolbarView: toolbarView,
            dismissAction: dismissAction
        )
    }

    /// Updates the `headerView` of the `MEGAPromotionalDialog` with a new type, using the old `headerView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `HeaderView` into a new `NewHeaderView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `headerView`.
    ///
    /// Example Usage:
    /// ```swift
    /// updatedHeaderView {
    ///     $0.property = newProperty
    ///     return $0
    /// }
    /// ```
    func updatedHeaderView<NewHeaderView: View>(
        _ transform: @escaping (inout HeaderView) -> NewHeaderView
    ) -> UpdatedHeaderView<NewHeaderView> {
        .init(
            headerView: {
                var newHeaderView = self.headerView()
                return transform(&newHeaderView)
            },
            headlineText: headlineText,
            smallTitleText: smallTitleText,
            bodyText: bodyText,
            textAlignment: textAlignment,
            ignoreSafeAreaEdges: ignoreSafeAreaEdges,
            hasCloseButtonOverlay: hasCloseButtonOverlay,
            contentView: contentView,
            footerView: footerView,
            toolbarView: toolbarView,
            dismissAction: dismissAction
        )
    }

    /// Updates the `footerView` of the `MEGAPromotionalDialog` with a new type, using the old `footerView` as a parameter.
    /// - Parameter transform: A closure that transforms the old `FooterView` into a new `NewFooterView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `footerView`.
    func updatedFooterView<NewFooterView: View>(
        _ transform: @escaping (inout FooterView) -> NewFooterView
    ) -> UpdatedFooterView<NewFooterView> {
        .init(
            headerView: headerView,
            headlineText: headlineText,
            smallTitleText: smallTitleText,
            bodyText: bodyText,
            textAlignment: textAlignment,
            ignoreSafeAreaEdges: ignoreSafeAreaEdges,
            hasCloseButtonOverlay: hasCloseButtonOverlay,
            contentView: contentView,
            footerView: {
                var newFooterView = self.footerView()
                return transform(&newFooterView)
            },
            toolbarView: toolbarView,
            dismissAction: dismissAction
        )
    }

    /// Updates the `toolbarView` of the `MEGAPromotionalDialog` with a new type, using the old `toolbarView` as a parameter.
    /// - Parameter transform: A closure that transforms the old `ToolbarView` into a new `NewToolbarView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `toolbarView`.
    func updatedToolbarView<NewToolbarView: View>(
        _ transform: @escaping (inout ToolbarView) -> NewToolbarView
    ) -> UpdatedToolbarView<NewToolbarView> {
        .init(
            headerView: headerView,
            headlineText: headlineText,
            smallTitleText: smallTitleText,
            bodyText: bodyText,
            textAlignment: textAlignment,
            ignoreSafeAreaEdges: ignoreSafeAreaEdges,
            hasCloseButtonOverlay: hasCloseButtonOverlay,
            contentView: contentView,
            footerView: footerView,
            toolbarView: {
                var newToolbarView = self.toolbarView()
                return transform(&newToolbarView)
            },
            dismissAction: dismissAction
        )
    }

    // MARK: - No Parameter

    /// Updates the `contentView` of the `MEGAPromotionalDialog` with a new type, without using the old view.
    /// - Parameter newContentView: A closure providing a new `NewContentView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `contentView`.
    func replaceContentView<NewContentView: View>(
        with newContentView: @escaping () -> NewContentView
    ) -> UpdatedContentView<NewContentView> {
        updatedContentView { _ in newContentView() }
    }

    /// Updates the `headerView` of the `MEGAPromotionalDialog` with a new type, without using the old view.
    /// - Parameter newHeaderView: A closure providing a new `NewHeaderView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `headerView`.
    func replaceHeaderView<NewHeaderView: View>(
        with newHeaderView: @escaping () -> NewHeaderView
    ) -> UpdatedHeaderView<NewHeaderView> {
        updatedHeaderView { _ in newHeaderView() }
    }

    /// Updates the `footerView` of the `MEGAPromotionalDialog` with a new type, without using the old view.
    /// - Parameter newFooterView: A closure providing a new `NewFooterView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `footerView`.
    func replaceFooterView<NewFooterView: View>(
        with newFooterView: @escaping () -> NewFooterView
    ) -> UpdatedFooterView<NewFooterView> {
        updatedFooterView { _ in newFooterView() }
    }

    /// Updates the `toolbarView` of the `MEGAPromotionalDialog` with a new type, without using the old view.
    /// - Parameter newToolbarView: A closure providing a new `NewToolbarView`.
    /// - Returns: A new `MEGAPromotionalDialog` instance with the updated `toolbarView`.
    func replaceToolbarView<NewToolbarView: View>(
        with newToolbarView: @escaping () -> NewToolbarView
    ) -> UpdatedToolbarView<NewToolbarView> {
        updatedToolbarView { _ in newToolbarView() }
    }

    // MARK: - Typealiases

    typealias UpdatedHeaderView<NewHeaderView: View> = MEGAPromotionalDialog<
        NewHeaderView,
        ContentView,
        FooterView,
        ToolbarView
    >

    typealias UpdatedContentView<NewContentView: View> = MEGAPromotionalDialog<
        HeaderView,
        NewContentView,
        FooterView,
        ToolbarView
    >

    typealias UpdatedFooterView<NewFooterView: View> = MEGAPromotionalDialog<
        HeaderView,
        ContentView,
        NewFooterView,
        ToolbarView
    >

    typealias UpdatedToolbarView<NewToolbarView: View> = MEGAPromotionalDialog<
        HeaderView,
        ContentView,
        FooterView,
        NewToolbarView
    >
}
