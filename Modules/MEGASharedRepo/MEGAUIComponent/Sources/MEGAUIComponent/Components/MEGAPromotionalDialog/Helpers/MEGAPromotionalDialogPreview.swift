// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public typealias MEGAPromotionalDialogPreview = MEGAPromotionalDialog<
    EmptyView,
    EmptyView,
    EmptyView,
    EmptyView
>

public extension MEGAPromotionalDialogPreview {
    init(
        headlineWordCount: Int = 12,
        smallTitleWordCount: Int = 12,
        bodyWordCount: Int = 48,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.init(
            headerView: { EmptyView() },
            headlineText: String.loremIpsum(headlineWordCount),
            smallTitleText: String.loremIpsum(smallTitleWordCount),
            bodyText: String.loremIpsum(bodyWordCount),
            toolbarView: { EmptyView() },
            dismissAction: dismissAction
        )
    }
}
