#if !targetEnvironment(macCatalyst)
import MEGAAnalyticsiOS

public protocol AnalyticsTracking {
    func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol)
}

extension Tracker: AnalyticsTracking {
    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        if let eventIdentifier = event.identifier {
            trackEvent(eventIdentifier: eventIdentifier)
        }
    }
}

extension Tracker {
    private static let sharedVPN: Tracker = {
        Tracker(
            viewIdProvider: viewIdProvider,
            appIdentifier: AppIdentifier(id: 1),
            eventSender: eventSender
        )
    }()

    private static let sharedPWM: Tracker = {
        Tracker(
            viewIdProvider: viewIdProvider,
            appIdentifier: AppIdentifier(id: 2),
            eventSender: eventSender
        )
    }()

    public static func shared(for sourceType: AnalyticsSource) -> Tracker {
        sourceType == .vpn ? sharedVPN : sharedPWM
    }

    static let viewIdProvider = ViewIdProviderAdapter(
        viewIdUseCase: ViewIDUseCase(viewIdRepo: ViewIDRepository.newRepo)
    )

    static let eventSender = EventSenderAdapter(
        analyticsUseCase: AnalyticsUseCase(analyticsRepo: AnalyticsRepository.newRepo)
    )
}
#endif
