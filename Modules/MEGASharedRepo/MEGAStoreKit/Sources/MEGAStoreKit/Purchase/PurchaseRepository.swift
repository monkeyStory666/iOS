// Copyright © 2023 MEGA Limited. All rights reserved.

@preconcurrency import Combine
import MEGASdk
import MEGASDKRepo
import MEGASwift

public final class PurchaseRepository: PurchaseRepositoryProtocol, @unchecked Sendable {
    @MainActor private var receiptsOngoingSubmission = [Receipt: AnyPublisher<Void, Error>]()

    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func submitPurchase(with receipt: String) async throws {
        let publisher = await receiptSubmissionPublisher(for: receipt)
        var cancellable: AnyCancellable?
        return try await withCheckedThrowingContinuation { continuation in
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            continuation.resume(returning: ())
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }, receiveValue: { _ in }
                )
        }
    }

    @MainActor
    private func receiptSubmissionPublisher(for receipt: Receipt) -> AnyPublisher<Void, Error> {
        if let ongoingPublisher = receiptsOngoingSubmission[receipt] {
            return ongoingPublisher
        } else {
            let publisher = createSubmitPurchasePublisher(for: receipt)
            addToOngoingSubmission(receipt, publisher)
            return publisher
        }
    }

    private func createSubmitPurchasePublisher(for receipt: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.sdk.submitPurchase(
                .itunes,
                receipt: receipt,
                delegate: RequestDelegate { [weak self] result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        switch error.type {
                        case .apiOk:
                            promise(.success(()))
                        case .apiEExpired:
                            promise(.failure(PurchaseError.expiredOrInvalidReceipt))
                        case .apiEExist:
                            promise(.failure(PurchaseError.alreadyExist))
                        case .apiEAccess:
                            promise(.failure(PurchaseError.receiptUsed))
                        default:
                            promise(.failure(PurchaseError.generic(error.localizedDescription)))
                        }
                    }
                    await self?.removeFromOngoingSubmission(receipt)
                }
            )
        }
        .eraseToAnyPublisher()
    }

    @MainActor
    private func addToOngoingSubmission(_ receipt: Receipt, _ publisher: AnyPublisher<Void, Error>) {
        receiptsOngoingSubmission[receipt] = publisher
    }

    @MainActor
    private func removeFromOngoingSubmission(_ receipt: Receipt) {
        receiptsOngoingSubmission.removeValue(forKey: receipt)
    }
}
