// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASwift
import StoreKit

extension StoreKitReceiptDelegate {
    /// This function will prioritize using local receipt in the user's device to process an action.
    /// In case the local receipt is not available or when the action throws an error,
    /// it will try again with a refreshed receipt from the StoreKit.
    static func processReceipt(with action: (Receipt) async throws -> Void) async throws {
        var localReceiptFetched: Receipt?

        do {
            let localReceipt = try await localReceipt()
            localReceiptFetched = localReceipt
            try await action(localReceipt)
        } catch {
            guard let receiptToResubmit = try await receiptToResubmit(
                afterSubmitting: localReceiptFetched,
                throwing: error
            ) else {
                throw error
            }

            try await action(receiptToResubmit)
        }
    }

    private static func receiptToResubmit(
        afterSubmitting localReceipt: Receipt?,
        throwing error: Error
    ) async throws -> Receipt? {
        let refreshedReceipt = try await refreshedReceipt()

        return refreshedReceipt != localReceipt ? refreshedReceipt : nil
    }

    private static func localReceipt() async throws -> Receipt {
        try await StoreKitReceiptDelegate.fetchLocalReceipt()
    }

    private static func refreshedReceipt() async throws -> Receipt {
        var receiptDelegate: SKRequestDelegate?
        return try await withCheckedThrowingContinuation { continuation in
            receiptDelegate = StoreKitReceiptDelegate(continuation: continuation)
            let request = SKReceiptRefreshRequest(receiptProperties: nil)
            request.delegate = receiptDelegate
            request.start()
        }
    }
}
