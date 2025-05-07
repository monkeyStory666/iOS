// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement

public extension PricingProductEntity {
    static func sample(
        storeKitIdentifier: String? = nil,
        durationInMonths: Int = 1,
        description: String? = nil,
        trialDurationInDays: Int = 0
    ) -> PricingProductEntity {
        PricingProductEntity(
            storeKitIdentifier: storeKitIdentifier,
            durationInMonths: durationInMonths,
            description: description,
            trialDurationInDays: trialDurationInDays
        )
    }
}
