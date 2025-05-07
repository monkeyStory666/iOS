// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGATest
import MEGAStoreKit

public final class MockPurchaseRepository:
    MockObject<MockPurchaseRepository.Action>,
    PurchaseRepositoryProtocol {
    public enum Action: Equatable {
        case submitPurchase(receipt: String)
    }

    public var _submitPurchase: Result<Void, Error>

    public init(submitPurchase: Result<Void, Error> = .success(())) {
        self._submitPurchase = submitPurchase
    }

    public func submitPurchase(with receipt: String) async throws {
        actions.append(.submitPurchase(receipt: receipt))
        try _submitPurchase.get()
    }
}
