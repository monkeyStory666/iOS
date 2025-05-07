// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGANotifications
import MEGATest

public final class MockNotificationPermissionUseCase:
    MockObject<MockNotificationPermissionUseCase.Action>,
    NotificationPermissionUseCaseProtocol {
    public enum Action {
        case requestPermission
        case hasPermission
        case status
    }

    public var _requestPermission: Result<Void, Error>
    public var _hasPermission: () -> Bool
    public var _status: NotificationPermissionStatus

    public init(
        requestPermission: Result<Void, Error> = .success(()),
        hasPermission: @escaping () -> Bool,
        status: NotificationPermissionStatus = .authorized
    ) {
        _requestPermission = requestPermission
        _hasPermission = hasPermission
        _status = status
    }

    public init(
        requestPermission: Result<Void, Error> = .success(()),
        hasPermission: Bool = false,
        status: NotificationPermissionStatus = .authorized
    ) {
        _requestPermission = requestPermission
        _hasPermission = { hasPermission }
        _status = status
    }

    public func requestPermission() async throws {
        actions.append(.requestPermission)
        _hasPermission = {
            switch self._requestPermission {
            case .success:
                true
            case .failure:
                false
            }
        }
        try _requestPermission.get()
    }

    public func hasPermission() async -> Bool {
        actions.append(.hasPermission)
        return _hasPermission()
    }

    public func status() async -> NotificationPermissionStatus {
        actions.append(.status)
        return _status
    }
}
