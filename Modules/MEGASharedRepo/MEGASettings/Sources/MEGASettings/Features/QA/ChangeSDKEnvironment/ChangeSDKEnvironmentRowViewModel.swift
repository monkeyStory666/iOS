// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAPresentation
import MEGAInfrastructure
import MEGASDKRepo
import SwiftUI

fileprivate extension SDKEnvironment {
    static var defaultEnvironment: SDKEnvironment {
        .production
    }
}

public final class ChangeSDKEnvironmentRowViewModel: NoRouteViewModel, @unchecked Sendable {
    @ViewProperty var environment: SDKEnvironment = .defaultEnvironment

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let changeSDKEnvironmentUseCase: any ChangeSDKEnvironmentUseCaseProtocol
    private let loginUseCase: any LoginUseCaseProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase,
        changeSDKEnvironmentUseCase: any ChangeSDKEnvironmentUseCaseProtocol = DependencyInjection.changeSDKEnvironmentUseCase,
        loginUseCase: any LoginUseCaseProtocol = MEGAAuthentication.DependencyInjection.loginUseCase
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.changeSDKEnvironmentUseCase = changeSDKEnvironmentUseCase
        self.loginUseCase = loginUseCase
        super.init()
        self.environment = featureFlagsUseCase.get(
            for: .sdkEnvironment
        ) ?? .defaultEnvironment
    }

    func select(_ environment: SDKEnvironment) async {
        self.environment = environment
        self.featureFlagsUseCase.set(
            environment,
            for: .sdkEnvironment
        )
        changeSDKEnvironmentUseCase.setSDKEnvironment(environment)
        // Renew session with updated SDK environment
        _ = await loginUseCase.loginSession()
    }
}
