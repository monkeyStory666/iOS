// Copyright © 2025 MEGA Limited. All rights reserved.

import UserNotifications

protocol LocalNotificationScheduling {
    func requestNotification(
        identifier: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllDeliveredNotifications()
    func removeAllPendingNotificationRequests()
}

// MARK: - Implementation

extension UNUserNotificationCenter: LocalNotificationScheduling {
    func requestNotification(
        identifier: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws {
        try await add(
            UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
        )
    }
}
