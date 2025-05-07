// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAStoreKit
import MEGATest

public final class MockMultipleProductStoreUseCase:
    MockObject<MockMultipleProductStoreUseCase.Action>,
    MultipleProductStoreUseCaseProtocol {

    public enum Action: Equatable {
        case productIdentifiers
        case getProduct(ProductIdentifier)
        case purchaseProduct(ProductIdentifier)
        case restorePurchases
        case eligibleIntroductoryOffers
        case handleTransactionUpdates
    }

    public var _productIdentifiers: [ProductIdentifier]
    public var _getProduct: (ProductIdentifier) -> StoreProduct?
    public var _eligibleIntroductoryOffers: [ProductIdentifier: StoreOffer]
    public var _purchaseProduct: Result<Void, Error>
    public var _restorePurchases: Result<Void, Error>

    public init(
        productIdentifiers: [ProductIdentifier] = [],
        getProduct: @escaping (ProductIdentifier) -> StoreProduct? = { _ in nil },
        eligibleIntroductoryOffers: [ProductIdentifier: StoreOffer] = [:],
        purchaseProduct: Result<Void, Error> = .success(()),
        restorePurchases: Result<Void, Error> = .success(())
    ) {
        _productIdentifiers = productIdentifiers
        _getProduct = getProduct
        _eligibleIntroductoryOffers = eligibleIntroductoryOffers
        _purchaseProduct = purchaseProduct
        _restorePurchases = restorePurchases
    }

    public func productIdentifiers() async -> [ProductIdentifier] {
        actions.append(.productIdentifiers)
        return _productIdentifiers
    }

    public func getProduct(with identifier: ProductIdentifier) async -> StoreProduct? {
        actions.append(.getProduct(identifier))
        return _getProduct(identifier)
    }

    public func purchaseProduct(with identifier: ProductIdentifier) async throws {
        actions.append(.purchaseProduct(identifier))
        try _purchaseProduct.get()
    }

    public func restorePurchases() async throws {
        actions.append(.restorePurchases)
        try _restorePurchases.get()
    }

    public func eligibleIntroductoryOffers() async -> [ProductIdentifier: StoreOffer] {
        actions.append(.eligibleIntroductoryOffers)
        return _eligibleIntroductoryOffers
    }

    public func handleTransactionUpdates() {
        actions.append(.handleTransactionUpdates)
    }
}
