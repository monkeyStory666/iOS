// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGATest
import MEGAStoreKit

public final class MockStoreRepository:
    MockObject<MockStoreRepository.Action>,
    StoreRepositoryProtocol {
    public enum Action: Equatable {
        case getProduct(identifier: String)
        case onBackgroundTransactionUpdate
        case purchaseProduct(identifier: String)
        case restorePurchase
        case canMakePayments
    }

    public var _getProduct: Result<StoreProduct, Error>
    public var _purchaseProduct: Result<Void, Error>
    public var _restorePurchase: Result<Void, Error>
    public var _canMakePayments: Bool

    private var transactionUpdateHandlers = [(Receipt) async throws -> Void]()
    private var purchaseProductClosures = [(Receipt) async throws -> Void]()
    private var restorePurchaseClosures = [(Receipt) async throws -> Void]()

    public init(
        getProduct: Result<StoreProduct, Error> = .success(.sample()),
        purchaseProduct: Result<Void, Error> = .success(()),
        restorePurchase: Result<Void, Error> = .success(()),
        canMakePayments: Bool = true
    ) {
        self._getProduct = getProduct
        self._purchaseProduct = purchaseProduct
        self._restorePurchase = restorePurchase
        self._canMakePayments = canMakePayments
    }

    public func getProduct(
        with identifier: String
    ) async throws -> StoreProduct {
        actions.append(.getProduct(identifier: identifier))
        return try _getProduct.get()
    }

    public func onBackgroundTransactionUpdate(
        _ validateReceipt: @Sendable @escaping (Receipt) async throws -> Void
    ) {
        actions.append(.onBackgroundTransactionUpdate)
        transactionUpdateHandlers.append(validateReceipt)
    }

    public func purchaseProduct(
        with identifier: String,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        actions.append(.purchaseProduct(identifier: identifier))
        purchaseProductClosures.append(validateReceipt)
        return try _purchaseProduct.get()
    }

    public func restorePurchase(
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        actions.append(.restorePurchase)
        restorePurchaseClosures.append(validateReceipt)
        return try _restorePurchase.get()
    }

    public func canMakePayments() -> Bool {
        actions.append(.canMakePayments)
        return _canMakePayments
    }
}

// MARK: - Helper functions

public extension MockStoreRepository {
    func triggerTransactionUpdateHandler(
        on index: Int = 0,
        with receipt: String
    ) async throws {
        guard transactionUpdateHandlers.count > index else {
            return assertionFailure("Trying to trigger nonexistent closure")
        }

        try await transactionUpdateHandlers[index](receipt)
    }

    func triggerPurchaseProductCompletion(
        on index: Int = 0,
        with receipt: String
    ) async throws {
        guard purchaseProductClosures.count > index else {
            return assertionFailure("Trying to trigger nonexistent closure")
        }

        try await purchaseProductClosures[index](receipt)
    }

    func triggerRestorePurchaseCompletion(
        on index: Int = 0,
        with receipt: String
    ) async throws {
        guard restorePurchaseClosures.count > index else {
            return assertionFailure("Trying to trigger nonexistent closure")
        }

        try await restorePurchaseClosures[index](receipt)
    }
}
