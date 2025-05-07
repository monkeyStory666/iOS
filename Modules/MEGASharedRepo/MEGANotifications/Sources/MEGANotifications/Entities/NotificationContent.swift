// Copyright © 2025 MEGA Limited. All rights reserved.

import UserNotifications

public struct NotificationContent {
    public let title: String
    public let body: String
    public let sound: NotificationSound?
    public let userInfo: [AnyHashable: Any]
    public let badge: Int?
    public let interruptionLevel: NotificationInterruptionLevel
    public let relevanceScore: Double

    public init(
        title: String,
        body: String,
        sound: NotificationSound? = .default,
        userInfo: [AnyHashable: Any] = [:],
        badge: Int? = nil,
        interruptionLevel: NotificationInterruptionLevel = .passive,
        relevanceScore: Double = 0.5
    ) {
        self.title = title
        self.body = body
        self.sound = sound
        self.userInfo = userInfo
        self.badge = badge
        self.interruptionLevel = interruptionLevel
        self.relevanceScore = relevanceScore
    }
}

// MARK: - UserNotifications Mapping

extension NotificationContent {
    var toUNNotificationContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound?.toUNNotificationSound
        content.userInfo = userInfo
        content.badge = badge.map { NSNumber(value: $0) }
        content.interruptionLevel = .init(from: interruptionLevel)
        content.relevanceScore = relevanceScore
        return content
    }
}
