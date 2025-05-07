// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func trailingChevron() -> UpdatedTrailingView<MEGAListImageAccessoryView> {
        replaceTrailingView {
            MEGAListImageAccessoryView(
                image: Image(systemName: "chevron.right"),
                size: .init(width: 8, height: 16),
                color: TokenColors.Icon.secondary.swiftUI
            )
        }
    }
}

#Preview {
    List {
        Group {
            MEGAListPreview()
                .trailingChevron()
            MEGAListPreview()
                .trailingChevron()
            MEGAListPreview()
                .trailingChevron()
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    .listStyle(GroupedListStyle())
}
