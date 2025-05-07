// Copyright © 2024 MEGA Limited. All rights reserved.

public struct PricingProductEntity: Equatable {
    public let storeKitIdentifier: String?
    public let durationInMonths: Int
    public let description: String?
    public let trialDurationInDays: Int

    public init(
        storeKitIdentifier: String?,
        durationInMonths: Int,
        description: String?,
        trialDurationInDays: Int
    ) {
        self.storeKitIdentifier = storeKitIdentifier
        self.durationInMonths = durationInMonths
        self.description = description
        self.trialDurationInDays = trialDurationInDays
    }
}

