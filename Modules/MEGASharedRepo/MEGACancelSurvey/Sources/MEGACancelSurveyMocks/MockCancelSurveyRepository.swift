// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGACancelSurvey
import MEGATest

public final class MockCancelSurveyRepository:
    MockObject<MockCancelSurveyRepository.Action>,
    CancelSurveyRepositoryProtocol {

    public enum Action: Equatable {
        case getCache
        case saveToCache(subscriptionId: String?)
        case submitCancelSurvey(
            reasons: [CancelSurveySelectedReason]?,
            subscriptionId: String?,
            canContact: Bool
        )
    }

    public var _cache: [String?: Bool]
    public var _submitCancelSurvey: Result<Void, Error>

    public init(
        cache: [String?: Bool] = [:],
        submitCancelSurvey: Result<Void, Error> = .success(())
    ) {
        _cache = cache
        _submitCancelSurvey = submitCancelSurvey
    }

    public func getCache() -> [String?: Bool] {
        actions.append(.getCache)
        return _cache
    }

    public func saveToCache(subscriptionId: String?) {
        actions.append(.saveToCache(subscriptionId: subscriptionId))
    }

    public func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason]?,
        subscriptionId: String?,
        canContact: Bool
    ) async throws {
        actions.append(.submitCancelSurvey(reasons: reasons, subscriptionId: subscriptionId, canContact: canContact))
        try _submitCancelSurvey.get()
    }
}
