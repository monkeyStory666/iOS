// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAStoreKit
import MEGATest

public final class MockStoreUseCase:
    MockObject<MockStoreUseCase.Action>,
    StoreUseCaseProtocol {
    public enum Action: Equatable {
        case purchaseProduct
        case restorePurchase
        case eligibleIntroductoryOffer
        case handleTransactionUpdates
        case getLocalizedPrice
        case getProduct
    }

    public var _purchaseProduct: Result<Void, Error>
    public var _restorePurchase: Result<Void, Error>
    public var _localizedPrice: String?
    public var _eligibleIntroductoryOffer: StoreOffer?
    public var _getProduct: StoreProduct?

    public init(
        purchaseProduct: Result<Void, Error> = .success(()),
        restorePurchase: Result<Void, Error> = .success(()),
        localizedPrice: String? = nil,
        eligibleIntroductoryOffer: StoreOffer? = nil,
        getProduct: StoreProduct? = nil
    ) {
        self._purchaseProduct = purchaseProduct
        self._restorePurchase = restorePurchase
        self._localizedPrice = localizedPrice
        self._eligibleIntroductoryOffer = eligibleIntroductoryOffer
        self._getProduct = getProduct
    }

    public func getLocalizedPriceTask(
        _ onPriceChange: @Sendable @escaping (String?) -> Void
    ) -> (task: Task<Void, Never>, cachedValue: String?) {
        actions.append(.getLocalizedPrice)
        return (Task {}, _localizedPrice)
    }

    public func purchaseProduct() async throws {
        actions.append(.purchaseProduct)
        return try _purchaseProduct.get()
    }

    public func restorePurchase() async throws {
        actions.append(.restorePurchase)
        return try _restorePurchase.get()
    }

    public func eligibleIntroductoryOffer() async -> StoreOffer? {
        actions.append(.eligibleIntroductoryOffer)
        return _eligibleIntroductoryOffer
    }

    public func handleTransactionUpdates() {
        actions.append(.handleTransactionUpdates)
    }

    public func getProduct() async -> StoreProduct? {
        actions.append(.getProduct)
        return _getProduct
    }
}
