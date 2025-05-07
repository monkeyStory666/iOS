// Copyright © 2025 MEGA Limited. All rights reserved.

public protocol LocalNotificationUseCaseProtocol {
    func requestNotification(
        identifier: String,
        content: NotificationContent,
        trigger: NotificationTrigger
    ) async throws
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func cancelPendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllDeliveredNotifications()
    func cancelAllPendingNotificationRequests()
}

public struct LocalNotificationUseCase: LocalNotificationUseCaseProtocol {
    private let localNotificationScheduler: any LocalNotificationScheduling

    init(localNotificationScheduler: some LocalNotificationScheduling) {
        self.localNotificationScheduler = localNotificationScheduler
    }

    public func requestNotification(
        identifier: String,
        content: NotificationContent,
        trigger: NotificationTrigger
    ) async throws {
        try await localNotificationScheduler.requestNotification(
            identifier: identifier,
            content: content.toUNNotificationContent,
            trigger: trigger.toUNNotificationTrigger
        )
    }

    public func removeDeliveredNotifications(
        withIdentifiers identifiers: [String]
    ) {
        localNotificationScheduler.removeDeliveredNotifications(
            withIdentifiers: identifiers
        )
    }

    public func cancelPendingNotificationRequests(
        withIdentifiers identifiers: [String]
    ) {
        localNotificationScheduler.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    public func removeAllDeliveredNotifications() {
        localNotificationScheduler.removeAllDeliveredNotifications()
    }

    public func cancelAllPendingNotificationRequests() {
        localNotificationScheduler.removeAllPendingNotificationRequests()
    }
}
