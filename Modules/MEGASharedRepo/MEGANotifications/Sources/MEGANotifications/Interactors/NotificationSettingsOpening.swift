// Copyright © 2024 MEGA Limited. All rights reserved.

import UIKit

public protocol NotificationSettingsOpening {
    func open() async throws
}

public enum NotificationSettingsOpenerError: Error {
    case urlInvalid
    case cannotOpenURL
    case failedToOpenURL
}

// MARK: - Implementation

extension UIApplication: NotificationSettingsOpening {
    public func open() async throws {
        guard let url = notificationSettingsURL() else {
            throw NotificationSettingsOpenerError.urlInvalid
        }

        if canOpenURL(url) {
            await open(url, options: [:])
        } else {
            throw NotificationSettingsOpenerError.cannotOpenURL
        }
    }
}

private func notificationSettingsURL() -> URL? {
    #if targetEnvironment(macCatalyst)
    macCatalystNotificationSettingsURL()
    #else
    if #available(iOS 16.0, *) {
        iOSNotificationSettingsURL()
    } else {
        iOSAppSettingsURL()
    }
    #endif
}

#if targetEnvironment(macCatalyst)
private func macCatalystNotificationSettingsURL() -> URL? {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    return URL(
        string: "x-apple.systempreferences"
        + ":com.apple.preference.notifications"
        + "?id=\(bundleIdentifier)"
    )
}
#else
@available(iOS 16.0, *)
private func iOSNotificationSettingsURL() -> URL? {
    URL(string: UIApplication.openNotificationSettingsURLString)
}

private func iOSAppSettingsURL() -> URL? {
    URL(string: UIApplication.openSettingsURLString)
}
#endif

