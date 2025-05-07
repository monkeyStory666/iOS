// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAInfrastructure

public struct QASettingsCheckAnalyticsEnabledUseCaseDecorator: CheckAnalyticsEnabledUseCaseProtocol {
    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let decoratee: any CheckAnalyticsEnabledUseCaseProtocol

    public init(
        featureFlagsUseCase: some FeatureFlagsUseCaseProtocol,
        decoratee: some CheckAnalyticsEnabledUseCaseProtocol
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.decoratee = decoratee
    }

    public func isAnalyticsEnabled() -> Bool {
        let featureFlag: AnalyticsQASettingsOption? = featureFlagsUseCase
            .get(for: .trackAnalyticsFlag)

        switch featureFlag {
        case .enabled:
            return true
        default:
            return decoratee.isAnalyticsEnabled()
        }
    }
}
