// Copyright © 2025 MEGA Limited. All rights reserved.

import UserNotifications

public enum NotificationInterruptionLevel {
    case passive
    case active
    case critical
    case timeSensitive
}

// MARK: - UserNotifications Mapping

extension UNNotificationInterruptionLevel {
    init(from interruptionLevel: NotificationInterruptionLevel) {
        switch interruptionLevel {
        case .passive:
            self = .passive
        case .active:
            self = .active
        case .critical:
            self = .critical
        case .timeSensitive:
            self = .timeSensitive
        }
    }
}
