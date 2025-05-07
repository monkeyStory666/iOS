// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGACancelSurvey
import MEGACancelSurveyMocks
import MEGASwift
import MEGATest
import Testing

struct CancelSurveyUseCaseTests {
    struct ShouldDisplayCancelSurveyArguments {
        let subscriptionId: String?
        let cache: [String?: Bool]
        let shouldDisplay: Bool
    }

    @Test(
        arguments: [
            ShouldDisplayCancelSurveyArguments(
                subscriptionId: .random(),
                cache: [:],
                shouldDisplay: true
            ),
            ShouldDisplayCancelSurveyArguments(
                subscriptionId: "expectedId",
                cache: ["expectedId": .random()],
                shouldDisplay: false
            ),
            ShouldDisplayCancelSurveyArguments(
                subscriptionId: "expectedId",
                cache: ["unexpectedId": .random()],
                shouldDisplay: true
            ),
            ShouldDisplayCancelSurveyArguments(
                subscriptionId: "expectedId",
                cache: [.random(): .random(), "expectedId": .random()],
                shouldDisplay: false
            ),
            ShouldDisplayCancelSurveyArguments(
                subscriptionId: nil,
                cache: [nil: .random()],
                shouldDisplay: false
            )
        ]
    ) func shouldDisplayCancelSurvey_shouldGetFromCache(
        arguments: ShouldDisplayCancelSurveyArguments
    ) {
        let mockRepo = MockCancelSurveyRepository(cache: arguments.cache)
        let sut = makeSUT(repository: mockRepo)

        #expect(sut.shouldDisplayCancelSurvey(for: arguments.subscriptionId) == arguments.shouldDisplay)
    }

    struct CancelSurveyArguments {
        let reasons: [CancelSurveySelectedReason]
        let subscriptionId: String?
        let canContact: Bool
    }

    @Test(
        arguments: [
            CancelSurveyArguments(
                reasons: [],
                subscriptionId: .random(),
                canContact: .random()
            ),
            CancelSurveyArguments(
                reasons: [
                    .init(text: .random(), position: .random()),
                    .init(text: .random(), position: .random())
                ],
                subscriptionId: nil,
                canContact: .random()
            )
        ]
    ) func submitCancelSurvey_shouldCallRepository(
        arguments: CancelSurveyArguments
    ) async throws {
        let mockRepo = MockCancelSurveyRepository()
        let sut = makeSUT(repository: mockRepo)

        try await sut.submitCancelSurvey(
            reasons: arguments.reasons,
            subscriptionId: arguments.subscriptionId,
            canContact: arguments.canContact
        )

        #expect(
            mockRepo.actions == [
                .saveToCache(subscriptionId: arguments.subscriptionId),
                .submitCancelSurvey(
                    reasons: arguments.reasons,
                    subscriptionId: arguments.subscriptionId,
                    canContact: arguments.canContact
                )
            ]
        )
    }

    @Test func submitCancelSurvey_whenFail_shouldStillSaveToCache() async throws {
        let expectedSubscriptionId = String.random()
        let mockRepo = MockCancelSurveyRepository(submitCancelSurvey: .failure(ErrorInTest()))
        let sut = makeSUT(repository: mockRepo)

        await #expect(
            performing: {
                try await sut.submitCancelSurvey(
                    reasons: [.init(text: .random(), position: .random())],
                    subscriptionId: expectedSubscriptionId,
                    canContact: .random()
                )
            },
            throws: { isError($0, equalTo: ErrorInTest()) }
        )

        mockRepo.swt.assert(
            .saveToCache(subscriptionId: expectedSubscriptionId),
            isCalled: .once
        )
    }

    @Test func skippedSurvey_whenWithNilReasonAndCanContactFalse_shouldSaveToCacheAndSubmitCancelSurvey() async throws {
        let expectedSubscriptionId = String.random()
        let mockRepo = MockCancelSurveyRepository()
        let sut = makeSUT(repository: mockRepo)

        try await sut.skippedSurvey(subscriptionId: expectedSubscriptionId)

        #expect(
            mockRepo.actions == [
                .saveToCache(subscriptionId: expectedSubscriptionId),
                .submitCancelSurvey(
                    reasons: [CancelSurveySelectedReason(text: "Skipped", position: 0)],
                    subscriptionId: expectedSubscriptionId,
                    canContact: false
                )
            ]
        )
    }

    @Test func skippedSurvey_whenFail_shouldStillSaveToCache() async throws {
        let expectedSubscriptionId = String.random()
        let mockRepo = MockCancelSurveyRepository(submitCancelSurvey: .failure(ErrorInTest()))
        let sut = makeSUT(repository: mockRepo)

        await #expect(
            performing: {
                try await sut.submitCancelSurvey(
                    reasons: [.init(text: .random(), position: .random())],
                    subscriptionId: expectedSubscriptionId,
                    canContact: .random()
                )
            },
            throws: { isError($0, equalTo: ErrorInTest()) }
        )

        mockRepo.swt.assert(
            .saveToCache(subscriptionId: expectedSubscriptionId),
            isCalled: .once
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repository: any CancelSurveyRepositoryProtocol = MockCancelSurveyRepository()
    ) -> CancelSurveyUseCase {
        CancelSurveyUseCase(
            repository: repository
        )
    }
}
