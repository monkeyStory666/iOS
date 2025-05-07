// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockAppEnvironmentUseCase:
    MockObject<MockAppEnvironmentUseCase.Action>,
    AppEnvironmentUseCaseProtocol {
    public enum Action: Equatable {
        case config(AppConfigurationEntity)

        public var isConfig: Bool {
            if case .config = self {
                return true
            } else {
                return false
            }
        }
    }

    public var configuration: AppConfigurationEntity

    public init(configuration: AppConfigurationEntity = .debug) {
        self.configuration = configuration
    }

    public func config(_ configuration: AppConfigurationEntity) {
        actions.append(.config(configuration))
        self.configuration = configuration
    }
}
