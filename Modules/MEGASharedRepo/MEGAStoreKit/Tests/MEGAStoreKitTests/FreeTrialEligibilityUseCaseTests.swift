// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAStoreKit
import MEGATest
import XCTest

final class FreeTrialEligibilityUseCaseTests: XCTestCase {
    func testIsEligibleForFreeTrial_whenGetPricingThrowsError_shouldReturnFalse() async {
        let sut = makeSUT(
            pricingRepository: MockPricingRepository(
                getPricing: .failure(ErrorInTest())
            )
        )

        let result = await sut.isEligibleForFreeTrial(.random())

        XCTAssertFalse(result)
    }

    func testIsEligibleForFreeTrial_whenGetPricingReturnEmptyProducts_shouldReturnFalse() async {
        let sut = makeSUT(
            pricingRepository: MockPricingRepository(
                getPricing: .success(.init(products: []))
            )
        )

        let result = await sut.isEligibleForFreeTrial(.random())

        XCTAssertFalse(result)
    }

    func testIsEligibleForFreeTrial_whenGetPricingReturnNoProductWithSameID_shouldReturnFalse() async {
        let identifier = String.random()
        let sut = makeSUT(
            pricingRepository: MockPricingRepository(
                getPricing: .success(.init(products: [
                    .sample(storeKitIdentifier: nil),
                    .sample(storeKitIdentifier: .random())
                ]))
            )
        )

        let result = await sut.isEligibleForFreeTrial(identifier)

        XCTAssertFalse(result)
    }

    func testIsEligibleForFreeTrial_whenProductIsNotEligibleForTrial_shouldReturnFalse() async {
        let identifier = String.random()
        let sut = makeSUT(
            pricingRepository: MockPricingRepository(
                getPricing: .success(.init(products: [
                    .sample(storeKitIdentifier: identifier, trialDurationInDays: .random(in: Int.min...0))
                ]))
            )
        )

        let result = await sut.isEligibleForFreeTrial(identifier)

        XCTAssertFalse(result)
    }

    func testEligibleForFreeTrial_whenProductIsEligibleForTrial_shouldReturnTrue() async {
        let identifier = String.random()
        let sut = makeSUT(
            pricingRepository: MockPricingRepository(
                getPricing: .success(.init(products: [
                    .sample(storeKitIdentifier: identifier, trialDurationInDays: .random(in: 1..<Int.max))
                ]))
            )
        )

        let result = await sut.isEligibleForFreeTrial(identifier)

        XCTAssertTrue(result)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        pricingRepository: some PricingRepositoryProtocol = MockPricingRepository()
    ) -> FreeTrialEligibilityUseCase {
        FreeTrialEligibilityUseCase(
            pricingRepository: pricingRepository
        )
    }
}
