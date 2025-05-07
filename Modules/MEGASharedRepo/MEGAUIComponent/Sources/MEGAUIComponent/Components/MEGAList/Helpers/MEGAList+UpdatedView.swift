// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension MEGAList {
    // MARK: - With Old Content View Parameter

    /// Updates the `contentView` of the `MEGAList` with a new type, using the old `contentView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `ContentView` into a new `NewContentView`.
    /// - Returns: A new `MEGAList` instance with the updated `contentView`.
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
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: {
                var newContentView = self.contentView()
                return transform(&newContentView)
            },
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    /// Updates the `leadingView` of the `MEGAList` with a new type, using the old `leadingView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `LeadingView` into a new `NewLeadingView`.
    /// - Returns: A new `MEGAList` instance with the updated `leadingView`.
    ///
    /// Example Usage:
    /// ```swift
    /// updatedLeadingView {
    ///     $0.property = newProperty
    ///     return $0
    /// }
    /// ```
    func updatedLeadingView<NewLeadingView: View>(
        _ transform: @escaping (inout LeadingView) -> NewLeadingView
    ) -> UpdatedLeadingView<NewLeadingView> {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: {
                var newLeadingView = self.leadingView()
                return transform(&newLeadingView)
            },
            trailingView: trailingView
        )
    }

    /// Updates the `trailingView` of the `MEGAList` with a new type, using the old `trailingView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `TrailingView` into a new `NewTrailingView`.
    /// - Returns: A new `MEGAList` instance with the updated `trailingView`.
    ///
    /// Example Usage:
    /// ```swift
    /// updatedTrailingView {
    ///     $0.property = newProperty
    ///     return $0
    /// }
    /// ```
    func updatedTrailingView<NewTrailingView: View>(
        _ transform: @escaping (inout TrailingView) -> NewTrailingView
    ) -> UpdatedTrailingView<NewTrailingView> {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: {
                var newTrailingView = self.trailingView()
                return transform(&newTrailingView)
            }
        )
    }

    /// Updates the `headerView` of the `MEGAList` with a new type, using the old `headerView` as an inout parameter.
    /// - Parameter transform: A closure that transforms the old `HeaderView` into a new `NewHeaderView`.
    /// - Returns: A new `MEGAList` instance with the updated `headerView`.
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
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: contentView,
            headerView: {
                var newHeaderView = self.headerView()
                return transform(&newHeaderView)
            },
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    /// Updates the `footerView` of the `MEGAList` with a new type, using the old `footerView` as a parameter.
    /// - Parameter transform: A closure that transforms the old `FooterView` into a new `NewFooterView`.
    /// - Returns: A new `MEGAList` instance with the updated `footerView`.
    func updatedFooterView<NewFooterView: View>(
        _ transform: @escaping (FooterView) -> NewFooterView
    ) -> UpdatedFooterView<NewFooterView> {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: contentView,
            headerView: headerView,
            footerView: { transform(self.footerView()) },
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    // MARK: - No Parameter

    /// Updates the `contentView` of the `MEGAList` with a new type, without using the old view.
    /// - Parameter newContentView: A closure providing a new `NewContentView`.
    /// - Returns: A new `MEGAList` instance with the updated `contentView`.
    func replaceContentView<NewContentView: View>(
        with newContentView: @escaping () -> NewContentView
    ) -> UpdatedContentView<NewContentView> {
        updatedContentView { _ in newContentView() }
    }

    /// Updates the `leadingView` of the `MEGAList` with a new type, without using the old view.
    /// - Parameter newLeadingView: A closure providing a new `NewLeadingView`.
    /// - Returns: A new `MEGAList` instance with the updated `leadingView`.
    func replaceLeadingView<NewLeadingView: View>(
        with newLeadingView: @escaping () -> NewLeadingView
    ) -> UpdatedLeadingView<NewLeadingView> {
        updatedLeadingView { _ in newLeadingView() }
    }

    /// Updates the `trailingView` of the `MEGAList` with a new type, without using the old view.
    /// - Parameter newTrailingView: A closure providing a new `NewTrailingView`.
    /// - Returns: A new `MEGAList` instance with the updated `trailingView`.
    func replaceTrailingView<NewTrailingView: View>(
        with newTrailingView: @escaping () -> NewTrailingView
    ) -> UpdatedTrailingView<NewTrailingView> {
        updatedTrailingView { _ in newTrailingView() }
    }

    /// Updates the `headerView` of the `MEGAList` with a new type, without using the old view.
    /// - Parameter newHeaderView: A closure providing a new `NewHeaderView`.
    /// - Returns: A new `MEGAList` instance with the updated `headerView`.
    func replaceHeaderView<NewHeaderView: View>(
        with newHeaderView: @escaping () -> NewHeaderView
    ) -> UpdatedHeaderView<NewHeaderView> {
        updatedHeaderView { _ in newHeaderView() }
    }

    /// Updates the `footerView` of the `MEGAList` with a new type, without using the old view.
    /// - Parameter newFooterView: A closure providing a new `NewFooterView`.
    /// - Returns: A new `MEGAList` instance with the updated `footerView`.
    func replaceFooterView<NewFooterView: View>(
        with newFooterView: @escaping () -> NewFooterView
    ) -> UpdatedFooterView<NewFooterView> {
        updatedFooterView { _ in newFooterView() }
    }

    // MARK: - Typealiases

    typealias UpdatedContentView<NewContentView: View> = MEGAList<
        NewContentView,
        LeadingView,
        TrailingView,
        HeaderView,
        FooterView
    >

    typealias UpdatedLeadingView<NewLeadingView: View> = MEGAList<
        ContentView,
        NewLeadingView,
        TrailingView,
        HeaderView,
        FooterView
    >

    typealias UpdatedTrailingView<NewTrailingView: View> = MEGAList<
        ContentView,
        LeadingView,
        NewTrailingView,
        HeaderView,
        FooterView
    >

    typealias UpdatedHeaderView<NewHeaderView: View> = MEGAList<
        ContentView,
        LeadingView,
        TrailingView,
        NewHeaderView,
        FooterView
    >

    typealias UpdatedFooterView<NewFooterView: View> = MEGAList<
        ContentView,
        LeadingView,
        TrailingView,
        HeaderView,
        NewFooterView
    >
}
