// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift


public extension AccountDetailsEntity {
    var proFlexiPlan: AccountPlanEntity? {
        plans.first { $0.type == .proFlexi }
    }

    var isProFlexi: Bool { proFlexiPlan != nil }

    func isProFlexiExpired(from now: Date = Date()) -> Bool {
        guard let expiry = proFlexiPlan?.expiry else { return false }

        return now.timeIntervalSince1970 > expiry
    }
}
