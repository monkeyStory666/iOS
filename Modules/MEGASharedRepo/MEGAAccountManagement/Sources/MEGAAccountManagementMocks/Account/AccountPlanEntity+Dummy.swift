// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement

public extension AccountPlanEntity {
    static func sample(
        subscriptionId: String? = nil,
        type: AccountPlanTypeEntity = .free,
        isProPlan: Bool = true,
        expiry: TimeInterval = .zero,
        features: [String] = [],
        isTrial: Bool = false
    ) -> Self {
        AccountPlanEntity(
            key: subscriptionId,
            type: type,
            isProPlan: isProPlan,
            expiry: expiry,
            features: features,
            isTrial: isTrial
        )
    }
}
