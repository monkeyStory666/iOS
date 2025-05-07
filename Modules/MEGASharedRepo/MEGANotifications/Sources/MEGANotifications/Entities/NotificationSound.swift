// Copyright © 2025 MEGA Limited. All rights reserved.

import UserNotifications

public enum NotificationSound {
    case `default`
    case defaultCritical
    case defaultRingtone
}

// MARK: - UserNotifications Mapping

extension NotificationSound {
    var toUNNotificationSound: UNNotificationSound {
        switch self {
        case .default:
            .default
        case .defaultCritical:
            .defaultCritical
        case .defaultRingtone:
            #if targetEnvironment(macCatalyst)
                .default
            #else
            if #available(iOS 15.2, *) {
                .defaultRingtone
            } else {
                .default
            }
            #endif
        }
    }
}
