// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAccountManagement

public protocol FetchProductIdentifierUseCaseProtocol {
    func productIdentifiers() async throws -> [ProductIdentifier]
}

public struct FetchProductIdentifierUseCase: FetchProductIdentifierUseCaseProtocol {
    private let storeKitIdentifierPredicate: (String) -> Bool
    private let pricingRepository: any PricingRepositoryProtocol

    public init(
        storeKitIdentifierPredicate: @escaping (String) -> Bool,
        pricingRepository: some PricingRepositoryProtocol
    ) {
        self.storeKitIdentifierPredicate = storeKitIdentifierPredicate
        self.pricingRepository = pricingRepository
    }

    public func productIdentifiers() async throws -> [ProductIdentifier] {
        try await pricingRepository.getPricing().products
            .compactMap {
                guard
                    let storeKitIdentifier = $0.storeKitIdentifier,
                    storeKitIdentifierPredicate(storeKitIdentifier)
                else { return nil }

                return ProductIdentifier(
                    identifier: storeKitIdentifier,
                    durationInMonths: $0.durationInMonths,
                    type: $0.durationInMonths > 12 ? .consumable : .autoRenewable
                )
            }
    }
}
