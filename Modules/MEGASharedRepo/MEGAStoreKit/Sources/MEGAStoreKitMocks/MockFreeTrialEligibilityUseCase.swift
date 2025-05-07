// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGATest
import MEGAStoreKit

public final class MockFreeTrialEligibilityUseCase:
    MockObject<MockFreeTrialEligibilityUseCase.Action>,
    FreeTrialEligibilityUseCaseProtocol {
    public enum Action: Equatable {
        case isEligibleForFreeTrial(productIdentifier: String)
    }

    public var _isEligibleForFreeTrial: Bool

    public init(_isEligibleForFreeTrial: Bool = true) {
        self._isEligibleForFreeTrial = _isEligibleForFreeTrial
    }

    public func isEligibleForFreeTrial(_ productIdentifier: String) async -> Bool {
        actions.append(.isEligibleForFreeTrial(productIdentifier: productIdentifier))
        return _isEligibleForFreeTrial
    }
}
