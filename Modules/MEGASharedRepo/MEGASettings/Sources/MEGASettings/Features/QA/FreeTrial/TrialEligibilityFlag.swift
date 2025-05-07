// Copyright © 2024 MEGA Limited. All rights reserved.

public enum TrialEligibilityFlag: String, Codable, CaseIterable {
    case useDefault = "Use Status from API"
    case forceDisable = "Force Ineligible"
    case forceEnable = "Force Eligible"

    public static var defaultFlag: TrialEligibilityFlag {
        .useDefault
    }
}
