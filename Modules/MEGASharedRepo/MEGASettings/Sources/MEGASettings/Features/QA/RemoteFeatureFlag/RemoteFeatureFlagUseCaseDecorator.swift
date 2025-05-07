// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAStoreKit

public struct RemoteFeatureFlagUseCaseDecorator: RemoteFeatureFlagUseCaseProtocol {
    private let decoratee: any RemoteFeatureFlagUseCaseProtocol
    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(
        decoratee: some RemoteFeatureFlagUseCaseProtocol,
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    ) {
        self.decoratee = decoratee
        self.featureFlagsUseCase = featureFlagsUseCase
    }

    public func get(for key: String) async -> RemoteFeatureFlagState {
        let featureFlag: RemoteFeatureFlagRowView.Option = featureFlagsUseCase.get(
            for: .toggleRemoteFlag
        ) ?? .defaultFlag

        switch featureFlag {
        case .forceEnable:
            return .enabled(value: 1)
        case .forceDisable:
            return .disabled
        case .useDefault:
            return await decoratee.get(for: key)
        }
    }
}
