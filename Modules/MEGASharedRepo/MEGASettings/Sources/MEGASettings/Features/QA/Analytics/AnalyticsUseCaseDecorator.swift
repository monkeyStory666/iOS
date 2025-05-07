// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAInfrastructure

public final class AnalyticsTrackerDecorator: MEGAAnalyticsTrackerProtocol, ObservableObject {
    @MainActor @Published public var eventsSent: [(
        date: Date,
        event: any AnalyticsEventEntityProtocol
    )] = []

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private var decoratee: any MEGAAnalyticsTrackerProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase,
        decoratee: some MEGAAnalyticsTrackerProtocol
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.decoratee = decoratee
    }

    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        #if !targetEnvironment(macCatalyst)
        let option: AnalyticsQASettingsOption? = featureFlagsUseCase.get(
            for: .trackAnalyticsFlag
        )

        if case .enabled(let displayLimit) = option {
            Task {
                await MainActor.run {
                    eventsSent.append((
                        date: Date(),
                        event: event
                    ))
                    let countsToBeRemoved = max(0, eventsSent.count - displayLimit)
                    eventsSent.removeFirst(countsToBeRemoved)
                }
            }
        }
        #endif

        decoratee.trackAnalyticsEvent(with: event)
    }
}
