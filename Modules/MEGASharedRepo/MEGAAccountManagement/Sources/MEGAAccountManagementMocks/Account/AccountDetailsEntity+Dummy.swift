// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement

public extension AccountDetailsEntity {
    static func sample(
        plans: [AccountPlanEntity] = [],
        features: [AccountFeatureEntity] = [],
        subscriptions: [AccountSubscriptionEntity] = []
    ) -> AccountDetailsEntity {
        AccountDetailsEntity(
            plans: plans,
            features: features,
            subscriptions: subscriptions
        )
    }
}
