// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGANotifications
import MEGATest

public final class MockNotificationSettingsOpener:
    MockObject<MockNotificationSettingsOpener.Action>,
    NotificationSettingsOpening {
    public enum Action {
        case open
    }

    public var _open: Result<Void, Error>

    public init(_open: Result<Void, Error> = .success(())) {
        self._open = _open
    }

    public func open() async throws {
        actions.append(.open)
        return try _open.get()
    }
}
