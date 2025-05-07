// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAUIComponent
import MEGAInfrastructure
import MEGAStoreKit
import SwiftUI

public final class SimulateAppStorePriceChangeRowViewModel: NoRouteViewModel, @unchecked Sendable {
    @ViewProperty var priceOverrides: [String: String] = [:]
    @ViewProperty var cachedAppStorePrice: [String: String] = [:]

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let storePriceCacheUseCase: any StorePriceCacheUseCaseProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase,
        storePriceCacheUseCase: any StorePriceCacheUseCaseProtocol = MEGAStoreKit.DependencyInjection.storePriceCacheUseCase
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.storePriceCacheUseCase = storePriceCacheUseCase
        super.init()
        if let cachedPriceOverrides: [String: String] = featureFlagsUseCase.get(for: .simulateStorePricesChanged) {
            self.priceOverrides = cachedPriceOverrides
        }
    }

    func onAppear() async {
        cachedAppStorePrice = storePriceCacheUseCase.getPrices()
    }

    func updatePriceOverride(for key: String, with value: String?) {
        var updatedPriceOverrides = priceOverrides
        if let value, !value.isEmpty {
            updatedPriceOverrides[key] = value
        } else {
            updatedPriceOverrides.removeValue(forKey: key)
        }
        priceOverrides = updatedPriceOverrides
        featureFlagsUseCase.set(updatedPriceOverrides, for: .simulateStorePricesChanged)
    }
}
