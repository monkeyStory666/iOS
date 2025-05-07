// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure

public protocol CheckAnalyticsEnabledUseCaseProtocol {
    func isAnalyticsEnabled() -> Bool
}

public struct CheckAnalyticsEnabledUseCase: CheckAnalyticsEnabledUseCaseProtocol {
    private let appEnvironmentUseCase: any AppEnvironmentUseCaseProtocol

    public init(appEnvironmentUseCase: some AppEnvironmentUseCaseProtocol) {
        self.appEnvironmentUseCase = appEnvironmentUseCase
    }

    public func isAnalyticsEnabled() -> Bool {
        switch appEnvironmentUseCase.configuration {
        case .production:
            true
        default:
            false
        }
    }
}
