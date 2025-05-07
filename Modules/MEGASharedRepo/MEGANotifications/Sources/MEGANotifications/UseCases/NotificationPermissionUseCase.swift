// Copyright © 2023 MEGA Limited. All rights reserved.

import UserNotifications

public protocol NotificationPermissionUseCaseProtocol {
    func requestPermission() async throws
    func hasPermission() async -> Bool
    func status() async -> NotificationPermissionStatus
}

public struct NotificationPermissionUseCase: NotificationPermissionUseCaseProtocol {
    public enum Error: Swift.Error {
        case notGranted
    }

    private let notificationRequester: NotificationPermissionRequesting

    init(notificationRequester: NotificationPermissionRequesting) {
        self.notificationRequester = notificationRequester
    }

    public func requestPermission() async throws {
        guard try await notificationRequester.requestAuthorization(
            option: [.alert, .badge, .sound]
        ) == true else {
            throw Error.notGranted
        }
    }

    public func hasPermission() async -> Bool {
        await notificationRequester.authorizationStatus() == .authorized
    }

    public func status() async -> NotificationPermissionStatus {
        switch await notificationRequester.authorizationStatus() {
        case .authorized, .ephemeral, .provisional:
           .authorized
        case .denied:
           .denied
        case .notDetermined:
           .notDetermined
        @unknown default:
           .notDetermined
        }
    }
}
