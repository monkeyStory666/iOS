// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGACancelSurvey
import MEGATest

public final class MockCancelSurveyUseCase:
    MockObject<MockCancelSurveyUseCase.Action>,
    CancelSurveyUseCaseProtocol {
    public enum Action: Equatable {
        case shouldDisplayCancelSurvey(subscriptionId: String?)
        case submitCancelSurvey(reasons: [CancelSurveySelectedReason], subscriptionId: String?, canContact: Bool)
        case skippedSurvey(subscriptionId: String?)
    }

    public var _shouldDisplayCancelSurvey: Bool
    public var _submitCancelSurvey: Result<Void, Error>
    public var _skippedSurvey: Result<Void, Error>

    public init(
        shouldDisplayCancelSurvey: Bool = true,
        submitCancelSurvey: Result<Void, Error> = .success(()),
        skippedSurvey: Result<Void, Error> = .success(())
    ) {
        _shouldDisplayCancelSurvey = shouldDisplayCancelSurvey
        _submitCancelSurvey = submitCancelSurvey
        _skippedSurvey = skippedSurvey
    }

    public func shouldDisplayCancelSurvey(for subscriptionId: String?) -> Bool {
        actions.append(.shouldDisplayCancelSurvey(subscriptionId: subscriptionId))
        return _shouldDisplayCancelSurvey
    }

    public func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason],
        subscriptionId: String?,
        canContact: Bool
    ) async throws {
        actions.append(.submitCancelSurvey(reasons: reasons, subscriptionId: subscriptionId, canContact: canContact))
        try _submitCancelSurvey.get()
    }

    public func skippedSurvey(subscriptionId: String?) async throws {
        actions.append(.skippedSurvey(subscriptionId: subscriptionId))
        try _skippedSurvey.get()
    }
}
