// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGANotifications
import MEGATest
import UserNotifications

public final class MockNotificationPermissionRequester:
    MockObject<MockNotificationPermissionRequester.Action>,
    NotificationPermissionRequesting {
    public enum Action: Equatable {
        case requestAuthorization(option: UNAuthorizationOptions)
        case authorizationStatus
    }

    public var _requestAuthorization: Result<Bool, Error>
    public var _authorizationStatus: UNAuthorizationStatus

    public init(
        requestAuthorization: Result<Bool, Error> = .success(true),
        authorizationStatus: UNAuthorizationStatus = .notDetermined
    ) {
        _requestAuthorization = requestAuthorization
        _authorizationStatus = authorizationStatus
    }

    public func requestAuthorization(option: UNAuthorizationOptions) async throws -> Bool {
        actions.append(.requestAuthorization(option: option))
        return try _requestAuthorization.get()
    }

    public func authorizationStatus() async -> UNAuthorizationStatus {
        actions.append(.authorizationStatus)
        return _authorizationStatus
    }
}
