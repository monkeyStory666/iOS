// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGAStoreKit

public struct PurchaseRepositoryQASettingsDecorator: PurchaseRepositoryProtocol {
    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let decoratee: any PurchaseRepositoryProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol,
        decoratee: any PurchaseRepositoryProtocol
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.decoratee = decoratee
    }

    public func submitPurchase(with receipt: String) async throws {
        let featureFlagEnabled: Bool = featureFlagsUseCase.get(
            for: .simulateSDKPurchaseError
        ) ?? false

        if featureFlagEnabled {
            throw NSError(domain: #file, code: 0)
        } else {
            try await decoratee.submitPurchase(with: receipt)
        }
    }
}
