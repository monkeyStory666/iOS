// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGAStoreKit

public struct QASettingsStoreRepositoryDecorator: StoreRepositoryProtocol {
    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let storeKit: any StoreRepositoryProtocol
    private let legacyStoreKit: any StoreRepositoryProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol,
        storeKit: any StoreRepositoryProtocol,
        legacyStoreKit: any StoreRepositoryProtocol
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.storeKit = storeKit
        self.legacyStoreKit = legacyStoreKit
    }

    public func getProduct(with identifier: String) async throws -> StoreProduct {
        let storeRepository = storeRepository(when: .getProduct)
        var product = try await storeRepository.getProduct(with: identifier)
        checkForSimulatedPriceChange(for: &product)
        return product
    }

    private func checkForSimulatedPriceChange(for product: inout StoreProduct) {
        guard
            let cachedPriceOverrides: [String: String] = featureFlagsUseCase.get(for: .simulateStorePricesChanged),
            let priceOverride = cachedPriceOverrides[product.identifier]
        else { return }

        product = StoreProduct(
            name: product.name,
            identifier: product.identifier,
            price: .init(
                decimalPrice: product.price.priceFormatter(priceOverride) ?? product.price.decimalPrice,
                displayPrice: priceOverride,
                currencyCode: product.price.currencyCode,
                displayPriceFormatter: product.price.displayPriceFormatter,
                priceFormatter: product.price.priceFormatter
            ),
            offers: product.offers,
            isEligibleForIntroOffer: product.isEligibleForIntroOffer
        )
    }

    public func onBackgroundTransactionUpdate(
        _ validateReceipt: @Sendable @escaping (Receipt) async throws -> Void
    ) {
        // We should to listen to transaction updates in both versions of StoreKit
        storeKit.onBackgroundTransactionUpdate(validateReceipt)
        legacyStoreKit.onBackgroundTransactionUpdate(validateReceipt)
    }

    public func purchaseProduct(
        with identifier: String,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        if let error: StoreError = featureFlagsUseCase.get(for: .simulateStoreError) {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            throw error
        } else {
            try await storeRepository(when: .purchaseProduct)
                .purchaseProduct(with: identifier, validateReceipt)
        }
    }

    public func restorePurchase(
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        try await storeRepository(when: .restorePurchase)
            .restorePurchase(validateReceipt)
    }

    public func canMakePayments() -> Bool {
        storeRepository(when: .canMakePayments).canMakePayments()
    }

    private enum Method {
        case getProduct
        case purchaseProduct
        case restorePurchase
        case canMakePayments
    }

    private func storeRepository(when method: Method) -> any StoreRepositoryProtocol {
        switch (StoreKitVersion.qaOverriddenStoreKitVersion, method, Constants.isMacCatalyst) {
        case (.storeKit, _, _):
            return storeKit
        case (.legacyStoreKit, _, _):
            return legacyStoreKit
        case (_, .purchaseProduct, true):
            // Purchasing product in macOS using StoreKit 2 is broken, so we use StoreKit 1 for now
            return legacyStoreKit
        default:
            return storeKit
        }
    }
}
