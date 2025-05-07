// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAPresentation
import MEGASwift
import SwiftUI

public final class ListSectionViewModel: NoRouteViewModel {
    @ViewProperty public var rows: [any ListRowViewModel]
    @ViewProperty public var title: String

    public var shouldDisplayTitle: Bool {
        !title.isEmpty
    }

    public var isHidden: Bool {
        rows.allSatisfy { $0.isRowHidden }
    }

    public init(
        title: String = "",
        rows: [any ListRowViewModel]
    ) {
        self.title = title
        self.rows = rows

        Task {
            await rows.concurrentForEach { await $0.onLoad() }
        }
    }

    public func onRefresh() async {
        await rows.concurrentForEach { viewModel in
            guard let refreshable = viewModel as? (any Refreshable) else {
                return
            }

            await refreshable.onRefresh()
        }
    }
}

public extension Array where Element == ListSectionViewModel {
    var listView: some View {
        VStack(spacing: TokenSpacing._7) {
            ForEach(self, id: \.id) { viewModel in
                viewModel.view
            }
        }
    }
}

public extension ListSectionViewModel {
    var view: some View {
        ListSectionView(viewModel: self)
    }
}

public extension ListRowViewModel {
    var isRowHidden: Bool {
        (self as? (any Hidable))?.isHidden == true
    }
}

public extension Array where Element == any ListRowViewModel {
    var rowViews: some View {
        VStack(spacing: 0) {
            ForEach(self, id: \.id) { viewModel in
                if viewModel.isRowHidden {
                    EmptyView()
                } else {
                    AnyView(viewModel.rowView)
                }
            }
        }
    }
}
