// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum AppConfigurationEntity: CaseIterable, Sendable {
    case debug
    // swiftlint:disable:next identifier_name
    case qa
    case testFlight
    case production
}
