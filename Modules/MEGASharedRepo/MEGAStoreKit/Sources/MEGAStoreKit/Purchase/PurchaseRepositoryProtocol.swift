// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol PurchaseRepositoryProtocol {
    func submitPurchase(with receipt: String) async throws
}
