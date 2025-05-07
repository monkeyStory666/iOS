// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAStoreKit

public struct FreeTrialEligibilityUseCaseDecorator: FreeTrialEligibilityUseCaseProtocol {
    private let decoratee: any FreeTrialEligibilityUseCaseProtocol
    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(
        decoratee: some FreeTrialEligibilityUseCaseProtocol,
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    ) {
        self.decoratee = decoratee
        self.featureFlagsUseCase = featureFlagsUseCase
    }

    public func isEligibleForFreeTrial(_ productIdentifier: String) async -> Bool {
        let featureFlag: TrialEligibilityFlag = featureFlagsUseCase.get(
            for: .freeTrialEligibility
        ) ?? .defaultFlag

        switch featureFlag {
        case .forceEnable:
            return true
        case .forceDisable:
            return false
        case .useDefault:
            return await decoratee.isEligibleForFreeTrial(productIdentifier)
        }
    }
}
