// Copyright © 2025 MEGA Limited. All rights reserved.

enum AnalyticsQASettingsOption: Codable {
    case enabled(displayLimit: Int)
    case disabled

    var isEnabled: Bool {
        switch self {
        case .enabled: return true
        case .disabled: return false
        }
    }

    var displayLimit: Int? {
        switch self {
        case .enabled(let displayLimit): return displayLimit
        case .disabled: return nil
        }
    }
}
