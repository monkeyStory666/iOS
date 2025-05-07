// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGANotifications
import MEGATest

public final class MockNotificationRequestRegistrationUseCase:
    MockObject<MockNotificationRequestRegistrationUseCase.Action>,
    NotificationRequestRegistrationUseCaseProtocol {
    public enum Action {
        case registerForRemoteNotifications
    }

    public override init() {
        super.init()
    }

    public func registerForPushNotifications() {
        actions.append(.registerForRemoteNotifications)
    }
}
