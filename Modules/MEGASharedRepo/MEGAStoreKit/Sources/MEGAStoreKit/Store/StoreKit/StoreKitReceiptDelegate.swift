// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import StoreKit

public final class StoreKitReceiptDelegate: NSObject, SKRequestDelegate {
    var continuation: CheckedContinuation<Receipt, Error>

    init(continuation: CheckedContinuation<Receipt, Error>) {
        self.continuation = continuation
    }

    public func requestDidFinish(_ request: SKRequest) {
        guard request is SKReceiptRefreshRequest else { return }

        Task(priority: .userInitiated) {
            do {
                let localReceipt = try await Self.fetchLocalReceipt()
                continuation.resume(returning: localReceipt)
            } catch {
                continuation.resume(throwing: error)
            }
        }

        request.cancel()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKReceiptRefreshRequest else { return }

        continuation.resume(throwing: error)
        request.cancel()
    }

    public static func fetchLocalReceipt(
        retries: Int = 3
    ) async throws -> Receipt {
        guard let receiptURL = Bundle(for: Self.self).appStoreReceiptURL else {
            throw StoreError.system("Could not find the app store receipt URL")
        }

        var attempts = 0

        while attempts < retries {
            if FileManager.default.fileExists(atPath: receiptURL.path) {
                do {
                    let receiptData = try Data(contentsOf: receiptURL)
                    return receiptData.base64EncodedString()
                } catch {
                    throw StoreError.system("Failed to read receipt")
                }
            }

            attempts += 1

            // Wait for 1 second before retrying
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        throw StoreError.system("No receipt found after \(retries) retries")
    }
}
