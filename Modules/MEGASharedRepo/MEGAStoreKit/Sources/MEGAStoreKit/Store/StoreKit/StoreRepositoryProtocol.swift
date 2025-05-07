// Copyright © 2023 MEGA Limited. All rights reserved.

public typealias Receipt = String

public protocol StoreRepositoryProtocol {
    func getProduct(
        with identifier: String
    ) async throws -> StoreProduct

    func onBackgroundTransactionUpdate(
        _ validateReceipt: @Sendable @escaping (Receipt) async throws -> Void
    )

    func purchaseProduct(
        with identifier: String,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws

    func restorePurchase(
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws

    func canMakePayments() -> Bool
}
