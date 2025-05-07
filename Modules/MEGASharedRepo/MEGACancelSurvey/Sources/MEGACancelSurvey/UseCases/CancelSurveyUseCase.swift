// Copyright © 2025 MEGA Limited. All rights reserved.

public protocol CancelSurveyUseCaseProtocol {
    func shouldDisplayCancelSurvey(for subscriptionId: String?) -> Bool

    func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason],
        subscriptionId: String?,
        canContact: Bool
    ) async throws

    func skippedSurvey(subscriptionId: String?) async throws
}

public struct CancelSurveyUseCase: CancelSurveyUseCaseProtocol {
    private let repository: any CancelSurveyRepositoryProtocol

    public init(repository: some CancelSurveyRepositoryProtocol) {
        self.repository = repository
    }

    public func shouldDisplayCancelSurvey(for subscriptionId: String?) -> Bool {
        repository.getCache()[subscriptionId] == nil
    }

    public func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason],
        subscriptionId: String?,
        canContact: Bool
    ) async throws {
        repository.saveToCache(subscriptionId: subscriptionId)
        try await repository.submitCancelSurvey(
            reasons: reasons,
            subscriptionId: subscriptionId,
            canContact: canContact
        )
    }

    public func skippedSurvey(subscriptionId: String?) async throws {
        repository.saveToCache(subscriptionId: subscriptionId)
        try await repository.submitCancelSurvey(
            reasons: [CancelSurveySelectedReason(text: "Skipped", position: 0)],
            subscriptionId: subscriptionId,
            canContact: false
        )
    }
}
