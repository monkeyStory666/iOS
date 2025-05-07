// Copyright © 2024 MEGA Limited. All rights reserved.

import UIKit

public protocol NotificationRequestRegistrationUseCaseProtocol {
    func registerForPushNotifications() async
}

public struct NotificationRequestRegistrationUseCase: NotificationRequestRegistrationUseCaseProtocol {
    public init() {}

    @MainActor
    public func registerForPushNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
}
