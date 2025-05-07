// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct AppInformation: DiagnosticReadable, Sendable {
    public let appVersion: String
    public let buildNumber: String
    public let appName: String

    public var completeAppVersion: String {
        "\(appVersion) (\(buildNumber))"
    }

    init(
        appVersion: String?,
        buildNumber: String?,
        appName: String?
    ) {
        self.appVersion = appVersion ?? "(APP_VERSION)"
        self.buildNumber = buildNumber ?? "(APP_VERSION)"
        self.appName = appName ?? "(APP_NAME)"
    }

    public func readableDiagnostic() async -> String {
        """
        **App Information**
        App Name: \(appName)
        App Version: \(completeAppVersion)
        """
    }
}

public extension AppInformation {
    init() {
        self.init(
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            appName: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        )
    }
}
