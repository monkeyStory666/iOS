// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAStoreKit

public struct StorePriceCacheUseCaseDecorator: StorePriceCacheUseCaseProtocol {
    private let decoratee: any StorePriceCacheUseCaseProtocol
    private let featureFlagUseCase: any FeatureFlagsUseCaseProtocol

    public init(
        decoratee: some StorePriceCacheUseCaseProtocol,
        featureFlagUseCase: some FeatureFlagsUseCaseProtocol
    ) {
        self.decoratee = decoratee
        self.featureFlagUseCase = featureFlagUseCase
    }

    public func save(price: String, for identifier: String) {
        if let overriddenPrices: [String: String] = featureFlagUseCase.get(
            for: .simulateStorePricesChanged
        ), overriddenPrices.keys.contains(identifier) {
            return // We don't want to save overridden prices to cache
        }

        decoratee.save(price: price, for: identifier)
    }

    public func getPrice(for identifier: String) -> String? {
        decoratee.getPrice(for: identifier)
    }

    public func getPrices() -> [String: String] {
        decoratee.getPrices()
    }
}
