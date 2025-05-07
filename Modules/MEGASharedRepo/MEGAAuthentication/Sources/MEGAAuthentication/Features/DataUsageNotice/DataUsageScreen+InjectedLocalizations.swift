// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation

public struct DataUsageScreenLocalization {
    public let title: () -> String
    public let subtitle: () -> AttributedString
    public let agreeButtonTitle: () -> String

    public init(
        title: @escaping @autoclosure () -> String,
        subtitle: @escaping @autoclosure () -> AttributedString,
        agreeButtonTitle: @escaping @autoclosure () -> String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.agreeButtonTitle = agreeButtonTitle
    }
}
