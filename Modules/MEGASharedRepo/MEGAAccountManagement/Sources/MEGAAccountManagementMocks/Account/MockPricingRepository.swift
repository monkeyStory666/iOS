// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockPricingRepository: MockObject<MockPricingRepository.Action>, PricingRepositoryProtocol {
    public enum Action: Equatable {
        case getPricing
    }

    public var _getPricing: Result<PricingEntity, Error>

    public init(
        getPricing: Result<PricingEntity, Error> = .success(.init(products: []))
    ) {
        self._getPricing = getPricing
    }

    public func getPricing() async throws -> PricingEntity {
        actions.append(.getPricing)
        return try _getPricing.get()
    }
}
