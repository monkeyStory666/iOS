// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGASdk
import MEGASDKRepo
import MEGASwift

public protocol CancelSurveyRepositoryProtocol {
    func getCache() -> [String?: Bool]
    func saveToCache(subscriptionId: String?)
    func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason]?,
        subscriptionId: String?,
        canContact: Bool
    ) async throws
}

public struct CancelSurveyRepository: CancelSurveyRepositoryProtocol {
    public static let cacheKey = "CancelSurveyRepositoryCache"

    private let sdk: MEGASdk
    private let cacheService: any CacheServiceProtocol

    public init(
        sdk: MEGASdk,
        cacheService: some CacheServiceProtocol
    ) {
        self.sdk = sdk
        self.cacheService = cacheService
    }

    public func submitCancelSurvey(
        reasons: [CancelSurveySelectedReason]?,
        subscriptionId: String?,
        canContact: Bool
    ) async throws {
        try await withAsyncThrowingValue { completion in
            sdk.creditCardCancelSubscriptions(
                withReasons: {
                    let reasonList = MEGACancelSubscriptionReasonList.create()
                    reasons?.forEach { reasonList.add($0.toSDKType) }
                    return reasonList
                }(),
                subscriptionId: subscriptionId,
                canContact: canContact,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }

    public func saveToCache(subscriptionId: String?) {
        var cache = getCache()
        cache[subscriptionId] = true
        try? cacheService.save(cache, for: Self.cacheKey)
    }

    public func getCache() -> [String?: Bool] {
        (try? cacheService.fetch(for: Self.cacheKey)) ?? [:]
    }
}

extension CancelSurveySelectedReason {
    var toSDKType: MEGACancelSubscriptionReason {
        MEGACancelSubscriptionReason.create(text, position: String(position))
    }
}
