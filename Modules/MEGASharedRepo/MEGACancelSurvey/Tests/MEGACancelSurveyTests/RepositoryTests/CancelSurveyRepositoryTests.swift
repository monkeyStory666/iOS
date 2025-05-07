// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGACancelSurvey
@preconcurrency import MEGASdk
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGASDKRepo
import MEGASDKRepoMocks
import MEGASwift
import Testing

struct CancelSurveyRepositoryTests {
    struct SubmitCancelSurveyNoReasonArguments: Sendable {
        let subscriptionId: String?
        let canContact: Bool
    }

    @Test(
        arguments: [
            SubmitCancelSurveyNoReasonArguments(
                subscriptionId: nil,
                canContact: false
            ),
            SubmitCancelSurveyNoReasonArguments(
                subscriptionId: .random(),
                canContact: true
            )
        ]
    ) func submitCancelSurvey_whenSucceeds_andReasonNil(
        arguments: SubmitCancelSurveyNoReasonArguments
    ) async throws {
        let mockSdk = MockSdkCancelSurvey()
        let sut = makeSUT(sdk: mockSdk)

        try await sut.submitCancelSurvey(
            reasons: nil,
            subscriptionId: arguments.subscriptionId,
            canContact: arguments.canContact
        )

        #expect(mockSdk._cancelSubscriptionsCalls.count == 1)
        #expect(mockSdk._cancelSubscriptionsCalls.first?.reasonList?.size == 0)
        #expect(mockSdk._cancelSubscriptionsCalls.first?.subscriptionId == arguments.subscriptionId)
        #expect(mockSdk._cancelSubscriptionsCalls.first?.canContact == arguments.canContact)
    }

    @Test func submitCancelSurvey_whenSucceeds_andEmptyReason() async throws {
        let mockSdk = MockSdkCancelSurvey()
        let sut = makeSUT(sdk: mockSdk)

        try await sut.submitCancelSurvey(
            reasons: [],
            subscriptionId: .random(),
            canContact: .random()
        )

        #expect(mockSdk._cancelSubscriptionsCalls.count == 1)
        #expect(mockSdk._cancelSubscriptionsCalls.first?.reasonList?.size == 0)
    }

    @Test func submitCancelSurvey_whenSucceeds_withOneReason() async throws {
        let mockSdk = MockSdkCancelSurvey()
        let sut = makeSUT(sdk: mockSdk)

        try await sut.submitCancelSurvey(
            reasons: [
                CancelSurveySelectedReason(text: "reason", position: 5)
            ],
            subscriptionId: .random(),
            canContact: .random()
        )

        #expect(mockSdk._cancelSubscriptionsCalls.count == 1)
        let reason = try mockSdk.reason(at: 0)
        #expect(reason.text == "reason")
        #expect(reason.position == "5")
    }

    @Test func submitCancelSurvey_whenSucceeds_withMultipleReasons() async throws {
        let mockSdk = MockSdkCancelSurvey()
        let sut = makeSUT(sdk: mockSdk)

        try await sut.submitCancelSurvey(
            reasons: [
                CancelSurveySelectedReason(text: "reason1", position: 3),
                CancelSurveySelectedReason(text: "reason2", position: 1),
                CancelSurveySelectedReason(text: "reason3", position: 2)
            ],
            subscriptionId: .random(),
            canContact: .random()
        )

        #expect(mockSdk._cancelSubscriptionsCalls.count == 1)
        let reason1 = try mockSdk.reason(at: 0)
        #expect(reason1.text == "reason1")
        #expect(reason1.position == "3")

        let reason2 = try mockSdk.reason(at: 1)
        #expect(reason2.text == "reason2")
        #expect(reason2.position == "1")

        let reason3 = try mockSdk.reason(at: 2)
        #expect(reason3.text == "reason3")
        #expect(reason3.position == "2")
    }

    @Test func submitCancelSurvey_whenFails_shouldThrowError() async {
        let expectedError = MEGAError.anyError
        let sut = makeSUT(
            sdk: MockSdkCancelSurvey(
                cancelSubscriptionCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(
            performing: {
                try await sut.submitCancelSurvey(
                    reasons: [],
                    subscriptionId: .random(),
                    canContact: .random()
                )
            },
            throws: { isError($0, equalTo: expectedError) }
        )
    }

    @Test func saveToCache_shouldSaveToCache() {
        let expectedId: String? = String.random()
        let expectedObject: [String?: Bool] = [expectedId: true]
        let mockCacheService = MockCacheService()
        let sut = makeSUT(cacheService: mockCacheService)

        sut.saveToCache(subscriptionId: expectedId)

        mockCacheService.swt.assertActions(
            shouldBe: [
                .fetch(CancelSurveyRepository.cacheKey),
                .save(
                    .init(
                        object: expectedObject,
                        key: CancelSurveyRepository.cacheKey
                    )
                )
            ]
        )
    }

    @Test func saveToCache_shouldAppendCurrentCache_thenSave() {
        let savedId: String? = String.random()
        let expectedId: String? = String.random()

        let mockCacheService = MockCacheService(fetch: .success([savedId: true]))
        let sut = makeSUT(cacheService: mockCacheService)

        sut.saveToCache(subscriptionId: expectedId)

        mockCacheService.swt.assertActions(
            where: { action in
                if case .save(let param) = action {
                    guard
                        param.key == CancelSurveyRepository.cacheKey,
                        let cache = param.object as? [String?: Bool],
                        cache.count == 2,
                        cache[savedId] == true,
                        cache[expectedId] == true
                    else { return false }

                    return true
                }
                return false
            },
            isCalled: .once
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockSdkCancelSurvey = MockSdkCancelSurvey(),
        cacheService: CacheServiceProtocol = MockCacheService()
    ) -> CancelSurveyRepository {
        CancelSurveyRepository(sdk: sdk, cacheService: cacheService)
    }
}

final class MockSdkCancelSurvey: MEGASdk, @unchecked Sendable {
    struct CancelSubscriptionParameter {
        var reasonList: MEGACancelSubscriptionReasonList?
        var subscriptionId: String?
        var canContact: Bool
    }

    var _cancelSubscriptionsCalls = [CancelSubscriptionParameter]()

    var cancelSubscriptionCompletion: RequestDelegateStub

    init(
        cancelSubscriptionCompletion: @escaping RequestDelegateStub = requestDelegateFinished()
    ) {
        self.cancelSubscriptionCompletion = cancelSubscriptionCompletion
        super.init()
    }

    override func creditCardCancelSubscriptions(
        withReasons reasonList: MEGACancelSubscriptionReasonList?,
        subscriptionId: String?,
        canContact: Bool,
        delegate: any MEGARequestDelegate
    ) {
        _cancelSubscriptionsCalls.append(.init(
            reasonList: reasonList,
            subscriptionId: subscriptionId,
            canContact: canContact
        ))
        cancelSubscriptionCompletion(delegate, self)
    }

    func reason(at index: Int) throws -> MEGACancelSubscriptionReason {
        try #require(_cancelSubscriptionsCalls.last?.reasonList?.reason(at: index))
    }
}
