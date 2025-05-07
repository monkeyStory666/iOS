// Copyright © 2023 MEGA Limited. All rights reserved.

public enum AccountEligibility {
    case noActiveSubs
    case unsupportedPlan
    case eligible

    public var isEligible: Bool {
        self == .eligible
    }
}
