// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct AccountPlanEntity: Equatable, Codable, Sendable {
    public let key: String?
    public let type: AccountPlanTypeEntity
    public let isProPlan: Bool
    public let expiry: TimeInterval
    public let features: [String]
    public let isTrial: Bool

    public init(
        key: String?,
        type: AccountPlanTypeEntity,
        isProPlan: Bool,
        expiry: TimeInterval,
        features: [String],
        isTrial: Bool
    ) {
        self.key = key
        self.type = type
        self.isProPlan = isProPlan
        self.expiry = expiry
        self.features = features
        self.isTrial = isTrial
    }
}

public extension AccountPlanEntity {
    func isExpiredProFlexi(from now: Date) -> Bool {
        type == .proFlexi && now.timeIntervalSince1970 > expiry
    }
}
