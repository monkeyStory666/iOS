// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAUIComponent
import MEGAInfrastructure
import MEGAStoreKit
import SwiftUI

public final class SimulateStoreErrorRowViewModel: NoRouteViewModel {
    private static let errorReason = "Simulated error from QA settings"
    let errorOptions: [StoreError?] = [nil] + [
        .system(errorReason),
        .notAvailableInRegion,
        .invalid(errorReason),
        .generic(errorReason),
        .offerInvalid(errorReason),
        .networkError,
        .userCancelled
    ]

    @ViewProperty var storeError: StoreError?

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase) {
        self.featureFlagsUseCase = featureFlagsUseCase
        super.init()
        self.storeError = featureFlagsUseCase.get(for: .simulateStoreError)
    }

    func select(_ storeError: StoreError?) {
        self.storeError = storeError
        self.featureFlagsUseCase.set(storeError, for: .simulateStoreError)
    }
}
