// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct AccountFeatureEntity: Equatable, Codable, Sendable {
    public let featureId: String?
    public let expiry: TimeInterval

    public init(
        featureId: String?,
        expiry: TimeInterval
    ) {
        self.featureId = featureId
        self.expiry = expiry
    }
}
