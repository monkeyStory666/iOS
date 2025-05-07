// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGANotifications
import MEGATest

public final class MockLocalNotificationUseCase:
    MockObject<MockLocalNotificationUseCase.Action>,
    LocalNotificationUseCaseProtocol {
    public enum Action: Equatable {
        case requestNotification(identifier: String, content: NotificationContent, trigger: NotificationTrigger)
        case removeDeliveredNotifications(identifiers: [String])
        case cancelPendingNotificationRequests(identifiers: [String])
        case removeAllDeliveredNotifications
        case cancelAllPendingNotificationRequests
    }

    public var _requestNotification: Result<Void, Error>

    public init(requestNotification: Result<Void, Error> = .success(())) {
        _requestNotification = requestNotification
    }

    public func requestNotification(
        identifier: String,
        content: NotificationContent,
        trigger: NotificationTrigger
    ) async throws {
        actions.append(.requestNotification(identifier: identifier, content: content, trigger: trigger))
        try _requestNotification.get()
    }

    public func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        actions.append(.removeDeliveredNotifications(identifiers: identifiers))
    }

    public func cancelPendingNotificationRequests(withIdentifiers identifiers: [String]) {
        actions.append(.cancelPendingNotificationRequests(identifiers: identifiers))
    }

    public func removeAllDeliveredNotifications() {
        actions.append(.removeAllDeliveredNotifications)
    }

    public func cancelAllPendingNotificationRequests() {
        actions.append(.cancelAllPendingNotificationRequests)
    }
}

extension NotificationContent: Equatable {
    public static func == (
        lhs: MEGANotifications.NotificationContent,
        rhs: MEGANotifications.NotificationContent
    ) -> Bool {
        lhs.title == rhs.title &&
            lhs.body == rhs.body &&
            lhs.sound == rhs.sound &&
            lhs.userInfo.keys == rhs.userInfo.keys &&
            lhs.badge == rhs.badge &&
            lhs.interruptionLevel == rhs.interruptionLevel &&
            lhs.relevanceScore == rhs.relevanceScore
    }
}

extension NotificationTrigger: Equatable {
    public static func == (
        lhs: MEGANotifications.NotificationTrigger,
        rhs: MEGANotifications.NotificationTrigger
    ) -> Bool {
        switch (lhs, rhs) {
        case let (.timeInterval(lhsTimeInterval, lhsRepeats), .timeInterval(rhsTimeInterval, rhsRepeats)):
            return lhsTimeInterval == rhsTimeInterval && lhsRepeats == rhsRepeats
        case let (.calendar(lhsCalendar, lhsRepeats), .calendar(rhsCalendar, rhsRepeats)):
            return lhsCalendar == rhsCalendar && lhsRepeats == rhsRepeats
        default:
            return false
        }
    }
}
