// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift
import StoreKit
import SwiftUI

public final class StoreKitRepository: StoreRepositoryProtocol, @unchecked Sendable {
    public init() {}

    public func getProduct(
        with identifier: String
    ) async throws -> StoreProduct {
        try await mapErrorThrownToStoreError {
            let storeKitProduct = try await getStoreKitProduct(with: identifier)
            return StoreProduct(storeKitProduct: storeKitProduct)
        }
    }

    public func purchaseProduct(
        with identifier: String,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        try await mapErrorThrownToStoreError {
            let product = try await getStoreKitProduct(with: identifier)
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                try await handleSuccessfulTransaction(
                    verification: verification,
                    validateReceipt
                )
            case .userCancelled:
                throw StoreError.userCancelled
            case .pending:
                throw StoreError.pending
            @unknown default:
                throw StoreError.generic("Unknown purchase result occured")
            }
        }
    }

    public func restorePurchase(
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        try await mapErrorThrownToStoreError {
            try await StoreKitReceiptDelegate.processReceipt { receipt in
                try await validateReceipt(receipt)
            }
        }
    }

    public func onBackgroundTransactionUpdate(
        _ validateReceipt: @Sendable @escaping (Receipt) async throws -> Void
    ) {
        Task(priority: .background) {
            for await update in Transaction.updates {
                switch update {
                case let .verified(transaction):
                    do {
                        if await transaction.finishIfNeeded() {
                            break
                        }

                        try await StoreKitReceiptDelegate.processReceipt { receipt in
                            try await finishTransactionIfNeeded(transaction: transaction) {
                                try await validateReceipt(receipt)
                            }
                        }
                    } catch {
                        // do nothing because this will be a background process
                        // to update transaction status without any user input
                    }
                case .unverified:
                    break
                }
            }
        }
    }

    public func canMakePayments() -> Bool {
        AppStore.canMakePayments
    }

    // MARK: - Private functions

    private func getStoreKitProduct(
        with identifier: String
    ) async throws -> Product {
        guard let product = try await Product.products(for: [identifier]).first else {
            throw StoreError.notAvailableInRegion
        }

        return product
    }

    private func handleSuccessfulTransaction(
        verification: VerificationResult<StoreKit.Transaction>,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        switch verification {
        case .verified(let transaction):
            if await transaction.finishIfNeeded() {
                break
            }

            try await StoreKitReceiptDelegate.processReceipt { receipt in
                try await finishTransactionIfNeeded(transaction: transaction) {
                    try await validateReceipt(receipt)
                }
            }
        case let .unverified(_, verificationError):
            throw verificationError
        }
    }
}

extension StoreKit.Transaction {
    /// This function will finish the transaction if it's not needed to be updated anymore
    /// and return whether the transaction is finished or not.
    func finishIfNeeded() async -> Bool {
        if !shouldHandleUpdates {
            await finish()
            return true
        }

        return false
    }

    var isExpired: Bool {
        guard let expirationDate else { return false }

        return expirationDate.timeIntervalSinceNow <= 0
    }

    var isRevoked: Bool {
        revocationDate != nil
    }

    var shouldHandleUpdates: Bool {
        !isExpired && !isRevoked && !isUpgraded
    }
}
