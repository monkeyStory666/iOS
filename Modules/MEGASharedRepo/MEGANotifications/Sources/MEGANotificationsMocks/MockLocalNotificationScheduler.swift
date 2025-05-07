// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGANotifications
import UserNotifications
import MEGATest

public final class MockLocalNotificationScheduler:
    MockObject<MockLocalNotificationScheduler.Action>,
    LocalNotificationScheduling {
    public enum Action: Equatable {
        case requestNotification(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger)
        case removeDeliveredNotifications(identifiers: [String])
        case removePendingNotificationRequests(identifiers: [String])
        case removeAllDeliveredNotifications
        case removeAllPendingNotificationRequests
    }

    public var _requestNotification: Result<Void, Error>

    public init(requestNotification: Result<Void, Error> = .success(())) {
        _requestNotification = requestNotification
    }

    public func requestNotification(
        identifier: String,
        content: UNNotificationContent,
        trigger: UNNotificationTrigger
    ) async throws {
        actions.append(.requestNotification(identifier: identifier, content: content, trigger: trigger))
        try _requestNotification.get()
    }

    public func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        actions.append(.removeDeliveredNotifications(identifiers: identifiers))
    }

    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        actions.append(.removePendingNotificationRequests(identifiers: identifiers))
    }

    public func removeAllDeliveredNotifications() {
        actions.append(.removeAllDeliveredNotifications)
    }

    public func removeAllPendingNotificationRequests() {
        actions.append(.removeAllPendingNotificationRequests)
    }
}
