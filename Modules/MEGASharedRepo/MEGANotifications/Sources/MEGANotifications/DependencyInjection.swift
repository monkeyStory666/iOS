// Copyright © 2024 MEGA Limited. All rights reserved.

import UIKit
import UserNotifications

public enum DependencyInjection {
    public static var localNotificationUseCase: some LocalNotificationUseCaseProtocol {
        LocalNotificationUseCase(localNotificationScheduler: localNotificationScheduler)
    }

    public static var notificationPermissionUseCase: some NotificationPermissionUseCaseProtocol {
        NotificationPermissionUseCase(notificationRequester: permissionRequester)
    }

    public static var notificationRequestRegistrationUseCase: some NotificationRequestRegistrationUseCaseProtocol {
        NotificationRequestRegistrationUseCase()
    }

    public static var notificationSettingsOpener: some NotificationSettingsOpening {
        UIApplication.shared
    }

    // MARK: - Private Injections

    private static var localNotificationScheduler: some LocalNotificationScheduling {
        UNUserNotificationCenter.current()
    }
    private static var permissionRequester: some NotificationPermissionRequesting {
        UNUserNotificationCenter.current()
    }
}
