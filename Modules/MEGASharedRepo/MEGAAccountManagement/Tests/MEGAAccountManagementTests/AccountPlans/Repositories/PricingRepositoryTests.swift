// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGASdk
import MEGASDKRepo
import MEGASDKRepoMocks
import MEGASwift
import Testing

struct PricingRepositoryTests {
    @Test func getPricing_onSuccess() async throws {
        let sut = PricingRepository(
            sdk: MockPricingRepositorySdk(
                getPricingCompletion: requestDelegateFinished(
                    request: MockSdkRequest(
                        pricing: MockPricing(
                            iosID: ["com.mega.ios.1", "com.mega.ios.2"],
                            months: [1, 2],
                            description: ["description1", "description2"],
                            trialDurationInDays: [7, 14]
                        )
                    )
                )
            )
        )

        let entity = try await sut.getPricing()

        #expect(
            entity == PricingEntity(
                products: [
                    PricingProductEntity(
                        storeKitIdentifier: "com.mega.ios.1",
                        durationInMonths: 1,
                        description: "description1",
                        trialDurationInDays: 7
                    ),
                    PricingProductEntity(
                        storeKitIdentifier: "com.mega.ios.2",
                        durationInMonths: 2,
                        description: "description2",
                        trialDurationInDays: 14
                    )
                ]
            )
        )
    }

    @Test func getPricing_onEmpty() async throws {
        let sut = PricingRepository(
            sdk: MockPricingRepositorySdk(
                getPricingCompletion: requestDelegateFinished()
            )
        )

        let entity = try await sut.getPricing()

        #expect(entity == PricingEntity(products: []))
    }

    @Test func getPricing_onSdkError() async throws {
        let expectedError = MockSdkError.anyError
        let sut = PricingRepository(
            sdk: MockPricingRepositorySdk(
                getPricingCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(performing: {
            try await sut.getPricing()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }
}

private final class MockPricingRepositorySdk: MEGASdk, @unchecked Sendable {
    var getPricingCompletion: RequestDelegateStub

    init(
        getPricingCompletion: @escaping RequestDelegateStub
    ) {
        self.getPricingCompletion = getPricingCompletion
        super.init()
    }

    override func getPricingWith(_ delegate: any MEGARequestDelegate) {
        getPricingCompletion(delegate, self)
    }
}

private final class MockPricing: MEGAPricing {
    var _iosID: [String]
    var _months: [Int]
    var _description: [String?]
    var _trialDurationInDays: [UInt32]

    init(
        iosID: [String] = [],
        months: [Int] = [],
        description: [String?] = [],
        trialDurationInDays: [UInt32] = []
    ) {
        _iosID = iosID
        _months = months
        _description = description
        _trialDurationInDays = trialDurationInDays
    }

    override var products: Int { _iosID.count }

    override func iOSID(atProductIndex index: Int) -> String? {
        guard _iosID.count > index else { return nil }

        return _iosID[index]
    }

    override func months(atProductIndex index: Int) -> Int {
        guard _months.count > index else { return 0 }

        return _months[index]
    }

    override func description(atProductIndex index: Int) -> String? {
        guard _description.count > index else { return nil }

        return _description[index]
    }

    override func trialDurationInDays(atProductIndex index: Int) -> UInt32 {
        guard _trialDurationInDays.count > index else { return 0 }

        return _trialDurationInDays[index]
    }
}
