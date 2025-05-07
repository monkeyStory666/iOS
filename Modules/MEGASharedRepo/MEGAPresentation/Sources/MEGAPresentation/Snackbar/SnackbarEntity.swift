// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct SnackbarEntity {
    public static let defaultShowtime: TimeInterval = 4

    public var text: String
    public var showtime: TimeInterval = Self.defaultShowtime
    public var actionLabel: String?
    public var action: (() -> Void)?
    public var onDismiss: (() -> Void)?

    public init(
        text: String,
        showtime: TimeInterval = Self.defaultShowtime,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.showtime = showtime
        self.actionLabel = actionLabel
        self.action = action
        self.onDismiss = onDismiss
    }
}

extension SnackbarEntity: Equatable {
    public static func == (lhs: SnackbarEntity, rhs: SnackbarEntity) -> Bool {
        lhs.text == rhs.text
        && lhs.showtime == rhs.showtime
        && lhs.actionLabel == rhs.actionLabel
    }
}
