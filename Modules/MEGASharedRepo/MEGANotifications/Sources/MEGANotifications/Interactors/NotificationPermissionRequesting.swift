// Copyright © 2023 MEGA Limited. All rights reserved.

import UserNotifications

protocol NotificationPermissionRequesting {
    func requestAuthorization(option: UNAuthorizationOptions) async throws -> Bool
    func authorizationStatus() async -> UNAuthorizationStatus
}

// MARK: - Implementation

extension UNUserNotificationCenter: NotificationPermissionRequesting {
    func requestAuthorization(option: UNAuthorizationOptions) async throws -> Bool {
        try await requestAuthorization(options: option)
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}
