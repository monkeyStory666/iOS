// Copyright © 2024 MEGA Limited. All rights reserved.

public extension AccountDetailsEntity {
    var accountPlan: AccountPlanEntity? {
        plans.first(where: { $0.isProPlan && $0.type.isAccountPlan })
    }

    var accountPlanSubscription: AccountSubscriptionEntity? {
        subscriptions.first { $0.type.isAccountPlan }
    }

    var featurePlans: [AccountPlanEntity] {
        plans.filter { $0.type == .feature }
    }

    var featureSubscriptions: [AccountSubscriptionEntity] {
        subscriptions.filter { $0.type == .feature }
    }
}
