// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASwift
import StoreKit

/// This function will finish the assigned SKPaymentTransaction
/// in the SKPaymentQueue whenever a throwing action is successful
/// or thrown errors that are considered finishable errors.
func finishTransactionIfNeeded(
    transaction: SKPaymentTransaction,
    in queue: SKPaymentQueue,
    throwingAction: () async throws -> Void
) async throws {
    try await finishTransactionIfNeeded(
        throwingAction: throwingAction,
        finishAction: {
            queue.finishTransaction(transaction)
        }
    )
}

/// This function will finish the assigned StoreKit.Transaction
/// whenever a throwing action is successful or thrown errors
/// that are considered finishable errors.
func finishTransactionIfNeeded(
    transaction: StoreKit.Transaction,
    throwingAction: () async throws -> Void
) async throws {
    try await finishTransactionIfNeeded(
        throwingAction: throwingAction,
        finishAction: {
            await transaction.finish()
        }
    )
}

private func finishTransactionIfNeeded(
    throwingAction: () async throws -> Void,
    finishAction: () async -> Void
) async throws {
    do {
        try await throwingAction()
        await finishAction()
    } catch {
        if canFinishTransaction(whenError: error) {
            await finishAction()
        }

        throw error
    }
}

/// Function that returns a boolean value that indicates if the StoreKit transaction
/// should be finished in the StoreKit.
private func canFinishTransaction(whenError error: Error) -> Bool {
    if case PurchaseError.alreadyExist = error {
        return true
    } else {
        return false
    }
}
