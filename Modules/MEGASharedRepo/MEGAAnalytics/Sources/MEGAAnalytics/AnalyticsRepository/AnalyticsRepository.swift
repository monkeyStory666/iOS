import MEGASdk

public protocol AnalyticsRepositoryProtocol {
    func sendAnalyticsEvent(_ eventEntity: EventEntity)
}

public struct AnalyticsRepository: AnalyticsRepositoryProtocol {
    public static var newRepo: AnalyticsRepository {
        AnalyticsRepository(sdk: DependencyInjection.sharedSdk)
    }

    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func sendAnalyticsEvent(_ eventEntity: EventEntity) {
        sdk.sendEvent(eventEntity.id, message: eventEntity.message, addJourneyId: true, viewId: eventEntity.viewId)
    }
}
