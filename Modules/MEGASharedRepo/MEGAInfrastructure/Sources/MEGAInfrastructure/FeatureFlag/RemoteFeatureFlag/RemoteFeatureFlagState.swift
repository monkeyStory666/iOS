// Copyright © 2025 MEGA Limited. All rights reserved.

public enum RemoteFeatureFlagState: Equatable, Sendable {
    case disabled
    case enabled(value: Int)

    public var isEnabled: Bool {
        switch self {
        case .enabled: true
        default: false
        }
    }
}
