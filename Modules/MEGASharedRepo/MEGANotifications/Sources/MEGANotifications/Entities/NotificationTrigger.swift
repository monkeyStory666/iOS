// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import UserNotifications

public enum NotificationTrigger {
    case calendar(dateMatching: DateComponents, repeats: Bool)

    /// TimeInterval must be more than 1 second
    case timeInterval(_ timeInterval: TimeInterval, repeats: Bool)
}

// MARK: - UserNotifications Mapping

extension NotificationTrigger {
    var toUNNotificationTrigger: UNNotificationTrigger {
        switch self {
        case let .calendar(dateMatching, repeats):
            UNCalendarNotificationTrigger(
                dateMatching: dateMatching,
                repeats: repeats
            )
        case let .timeInterval(timeInterval, repeats):
            UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: repeats
            )
        }
    }
}
