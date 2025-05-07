// Copyright © 2024 MEGA Limited. All rights reserved.

public typealias AccountSubscriptionLevelEntity = Int

public extension AccountSubscriptionLevelEntity {
    var hasActiveFeaturePlan: Bool {
        self == 99_999
    }
}
