// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement

public protocol FreeTrialEligibilityUseCaseProtocol {
    func isEligibleForFreeTrial(_ productIdentifier: String) async -> Bool
}

public struct FreeTrialEligibilityUseCase: FreeTrialEligibilityUseCaseProtocol {
    private let pricingRepository: any PricingRepositoryProtocol

    public init(
        pricingRepository: some PricingRepositoryProtocol
    ) {
        self.pricingRepository = pricingRepository
    }

    public func isEligibleForFreeTrial(_ productIdentifier: String) async -> Bool {
        guard
            let pricing = try? await pricingRepository.getPricing(),
            let productToCheck = pricing.products.first(where: { $0.storeKitIdentifier == productIdentifier })
        else { return false }

        return productToCheck.eligibleForTrial
    }
}

extension PricingProductEntity {
    var eligibleForTrial: Bool {
        trialDurationInDays > 0
    }
}
