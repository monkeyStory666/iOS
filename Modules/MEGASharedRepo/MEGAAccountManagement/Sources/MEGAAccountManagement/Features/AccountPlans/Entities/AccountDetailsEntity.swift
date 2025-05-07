// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASharedRepoL10n

public struct AccountDetailsEntity: Equatable, Codable, Sendable {
    public let plans: [AccountPlanEntity]
    public let features: [AccountFeatureEntity]
    public let subscriptions: [AccountSubscriptionEntity]

    public init(
        plans: [AccountPlanEntity],
        features: [AccountFeatureEntity],
        subscriptions: [AccountSubscriptionEntity]
    ) {
        self.plans = plans
        self.features = features
        self.subscriptions = subscriptions
    }
}

public enum PaymentMethodEntity: Sendable, CaseIterable, Codable {
    case appleAppStore
    case googlePlayStore
    case webClient
}
