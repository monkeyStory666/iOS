// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift
import StoreKit

public final class LegacyStoreKitRepository: NSObject, StoreRepositoryProtocol, @unchecked Sendable {
    private var productRequestContinuation: CheckedContinuation<(SKProduct), Error>?

    private var purchasingTransaction: SKPaymentTransaction?
    private var purchaseContinuation: CheckedContinuation<(), Error>?
    private var purchaseCompletionHandler: ((Receipt) async throws -> Void)?

    private var restoreContinuation: CheckedContinuation<(), Error>?
    private var restoreCompletionHandler: ((Receipt) async throws -> Void)?

    private var transactionUpdateHandler: ((Receipt) async throws -> Void)?

    private let paymentQueue: SKPaymentQueue

    public init(paymentQueue: SKPaymentQueue = SKPaymentQueue.default()) {
        self.paymentQueue = paymentQueue
        super.init()
        paymentQueue.add(self)
    }

    deinit {
        paymentQueue.remove(self)
    }

    public func getProduct(with identifier: String) async throws -> StoreProduct {
        try await mapErrorThrownToStoreError {
            StoreProduct(skProduct: try await product(with: identifier))
        }
    }

    public func purchaseProduct(
        with identifier: String,
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        try await mapErrorThrownToStoreError {
            let product = try await product(with: identifier)
            try await withCheckedThrowingContinuation { [weak self] continuation in
                self?.purchaseCompletionHandler = validateReceipt
                self?.purchaseContinuation = continuation
                self?.paymentQueue.add(.init(product: product))
            }
        }
    }

    public func restorePurchase(
        _ validateReceipt: @escaping (Receipt) async throws -> Void
    ) async throws {
        try await mapErrorThrownToStoreError {
            try await withCheckedThrowingContinuation { [weak self] continuation in
                self?.restoreCompletionHandler = validateReceipt
                self?.restoreContinuation = continuation
                self?.paymentQueue.restoreCompletedTransactions()
            }
        }
    }

    public func onBackgroundTransactionUpdate(
        _ validateReceipt: @Sendable @escaping (Receipt) async throws -> Void
    ) {
        transactionUpdateHandler = validateReceipt
    }

    public func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    private func product(with identifier: String) async throws -> SKProduct {
        var productRequest: SKProductsRequest?
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.productRequestContinuation = continuation
            productRequest = SKProductsRequest(productIdentifiers: [identifier])
            productRequest?.delegate = self
            productRequest?.start()
        }
    }
}

extension LegacyStoreKitRepository: SKProductsRequestDelegate {
    public func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        if let product = response.products.first {
            productRequestFinished(with: product)
        } else {
            // We return not available in region when no products are found because
            // most likely this issue will only happen if the user in a region that
            // is not supported, thus the product doesn't exist.
            productRequestFailed(throwing: StoreError.notAvailableInRegion)
        }
        request.cancel()
    }

    public func request(
        _ request: SKRequest,
        didFailWithError error: Error
    ) {
        productRequestFailed(throwing: error)
        request.cancel()
    }

    private func productRequestFinished(with product: SKProduct) {
        productRequestContinuation?.resume(returning: product)
        resetProductRequestTask()
    }

    private func productRequestFailed(throwing error: Error) {
        productRequestContinuation?.resume(throwing: error)
        resetProductRequestTask()
    }

    private func resetProductRequestTask() {
        productRequestContinuation = nil
    }
}

extension LegacyStoreKitRepository: SKPaymentTransactionObserver {
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Task(priority: .background) { [weak self] in
            do {
                try await StoreKitReceiptDelegate.processReceipt { receipt in
                    try await self?.restoreCompletionHandler?(receipt)
                }
                self?.restoreProductFinished()
            } catch {
                self?.restoreProductFailed(throwing: error)
            }
        }
    }

    public func paymentQueue(
        _ queue: SKPaymentQueue,
        restoreCompletedTransactionsFailedWithError error: Error
    ) {
        restoreProductFailed(throwing: error)
    }

    public func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        handleBackgroundUpdate(updatedTransactions: transactions)

        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                onUpdate(purchasingTransaction: transaction, queue: queue)
            case .purchased:
                onUpdate(purchasedTransaction: transaction, queue: queue)
            case .failed:
                onUpdate(failedTransaction: transaction, queue: queue)
            case .restored:
                onUpdate(restoredTransaction: transaction, queue: queue)
            case .deferred:
                onUpdate(deferredTransaction: transaction, queue: queue)
            @unknown default:
                break
            }
        }

        unstuckPurchasingTask(transactions: transactions, queue: queue)
    }

    // MARK: - Private functions

    private func handleBackgroundUpdate(
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        guard !activeTransactionTaskExist() else { return }
        guard transactions.hasUnfinishedPurchasedTransaction else { return }

        Task(priority: .background) { [weak self] in
            do {
                try await StoreKitReceiptDelegate.processReceipt { receipt in
                    try await self?.transactionUpdateHandler?(receipt)
                }
            } catch {
                // do nothing because this will be a background process
                // to update transaction status without any user input
            }
        }
    }

    private func activeTransactionTaskExist() -> Bool {
        purchaseContinuation != nil || restoreContinuation != nil
    }

    /// This is a function to check if purchasing has not start and the transactions list don't contain
    /// a purchasing transaction, we can finish purchasing tasks with a failure.
    ///
    /// Sometimes when we add a new purchase to the payment queue, the updatedTransactions delegate
    /// function is called but there is no purchasing transaction in the array of transactions. This
    /// causes the continuation to never be called thus the user will get stuck in the loading HUD.
    ///
    /// We should do this after iterating through all transactions, so that we give time for all
    /// stuck transactions to be finished to reduce the change of purchasing task being stuck
    /// again when user try to make another purchase.
    private func unstuckPurchasingTask(
        transactions: [SKPaymentTransaction],
        queue: SKPaymentQueue
    ) {
        let purchaseHasNotStart = purchasingTransaction == nil
        let noPurchasingTransactions = !transactions.isEmpty && transactions.allSatisfy {
            $0.transactionState != .purchasing
        }

        guard purchaseHasNotStart && noPurchasingTransactions else { return }

        purchaseProductFailed(throwing: StoreError.system("Transactions stuck in payment queue"))
    }

    private func onUpdate(
        purchasingTransaction: SKPaymentTransaction,
        queue: SKPaymentQueue
    ) {
        self.purchasingTransaction = purchasingTransaction
    }

    private func onUpdate(
        purchasedTransaction: SKPaymentTransaction,
        queue: SKPaymentQueue
    ) {
        guard isPurchasingTransaction(purchasedTransaction) else {
            // We want to finish purchased transactions that is not
            // the transaction that user is purchasing because they
            // are old transactions that reenter the payment queue
            // because of the restore completed purchases flow.
            queue.finishTransaction(purchasedTransaction)
            return
        }

        Task(priority: .background) { [weak self] in
            do {
                try await StoreKitReceiptDelegate.processReceipt { receipt in
                    try await finishTransactionIfNeeded(
                        transaction: purchasedTransaction,
                        in: queue
                    ) {
                        try await self?.purchaseCompletionHandler?(receipt)
                    }
                }
                self?.purchaseProductFinished()
            } catch {
                self?.purchaseProductFailed(throwing: error)
            }
        }
    }

    private func onUpdate(
        failedTransaction: SKPaymentTransaction,
        queue: SKPaymentQueue
    ) {
        defer {
            // We want to always finish failed transactions so
            // they don't get stuck in the payment queue.
            queue.finishTransaction(failedTransaction)
        }

        guard isPurchasingTransaction(failedTransaction) else { return }

        purchaseProductFailed(
            throwing: failedTransaction.error
                ?? StoreError.generic("Transaction failed without error")
        )
    }

    /// We want to finish restored transactions so they
    /// don't get stuck in payment queue.
    ///
    /// We handled the purchase restoration separately
    /// in `paymentQueueRestoreCompletedTransactionsFinished`
    /// by fetching the latest receipt and submitting that receipt
    /// to our SDK.
    private func onUpdate(
        restoredTransaction: SKPaymentTransaction,
        queue: SKPaymentQueue
    ) {
        queue.finishTransaction(restoredTransaction)
    }

    private func onUpdate(
        deferredTransaction: SKPaymentTransaction,
        queue: SKPaymentQueue
    ) {
        guard isPurchasingTransaction(deferredTransaction) else { return }

        purchaseProductFailed(throwing: StoreError.pending)
    }

    private func isPurchasingTransaction(_ transaction: SKPaymentTransaction) -> Bool {
        purchaseContinuation != nil && transaction == purchasingTransaction
    }

    private func purchaseProductFinished() {
        purchaseContinuation?.resume()
        resetPurchaseProductTask()
    }

    private func purchaseProductFailed(throwing error: Error) {
        purchaseContinuation?.resume(throwing: error)
        resetPurchaseProductTask()
    }

    private func resetPurchaseProductTask() {
        purchasingTransaction = nil
        purchaseCompletionHandler = nil
        purchaseContinuation = nil
    }

    private func restoreProductFinished() {
        restoreContinuation?.resume()
        resetRestoreProductTask()
    }

    private func restoreProductFailed(throwing error: Error) {
        restoreContinuation?.resume(throwing: error)
        resetRestoreProductTask()
    }

    private func resetRestoreProductTask() {
        restoreCompletionHandler = nil
        restoreContinuation = nil
    }
}

extension Array where Element == SKPaymentTransaction {
    var hasUnfinishedPurchasedTransaction: Bool {
        contains(where: { $0.transactionState == .purchased })
    }
}
