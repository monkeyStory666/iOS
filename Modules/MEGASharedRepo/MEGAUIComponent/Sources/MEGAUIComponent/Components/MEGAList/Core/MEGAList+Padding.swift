// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public enum MEGAListPaddedSection: CaseIterable {
    case content
    case header
    case footer
}

public extension MEGAList {
    func setPadding(_ padding: [MEGAListPaddedSection: [ViewPaddingEntity]]) -> Self {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: padding,
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    func setPadding(_ padding: [ViewPaddingEntity]) -> Self {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: .init(padding: padding),
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    func addPadding(_ padding: [ViewPaddingEntity]) -> Self {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: self.padding.appended(padding),
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }

    func addPadding(_ paddedSection: MEGAListPaddedSection, _ padding: [ViewPaddingEntity]) -> Self {
        .init(
            contentBorderEdges: contentBorderEdges,
            padding: self.padding.appended(paddedSection, padding: padding),
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }
}

public extension Dictionary where Key == MEGAListPaddedSection, Value == Array<ViewPaddingEntity> {
    static var megaListDefaultPadding: [MEGAListPaddedSection: [ViewPaddingEntity]] {
        [
            .content: [ViewPaddingEntity(edges: .horizontal, amount: TokenSpacing._5)],
            .header: [ViewPaddingEntity(edges: .horizontal, amount: TokenSpacing._5)],
            .footer: [ViewPaddingEntity(edges: .horizontal, amount: TokenSpacing._5)]
        ]
    }

    init(padding: [ViewPaddingEntity]) {
        self.init(uniqueKeysWithValues: MEGAListPaddedSection.allCases.map { ($0, padding) })
    }

    mutating func append(_ paddedSection: MEGAListPaddedSection, padding: [ViewPaddingEntity]) {
        if let currentPadding = self[paddedSection] {
            self[paddedSection] = currentPadding + padding
        } else {
            self[paddedSection] = padding
        }
    }

    mutating func append(_ padding: [ViewPaddingEntity]) {
        MEGAListPaddedSection.allCases.forEach { append($0, padding: padding) }
    }

    func appended(_ paddedSection: MEGAListPaddedSection, padding: [ViewPaddingEntity]) -> Self {
        var copy = self
        copy.append(paddedSection, padding: padding)
        return copy
    }

    func appended(_ padding: [ViewPaddingEntity]) -> Self {
        var copy = self
        copy.append(padding)
        return copy
    }
}
