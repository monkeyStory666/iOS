// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public final class FeatureFlagToggleRowViewModel: NoRouteViewModel {
    @ViewProperty var isEnabled = false

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    let title: String
    let footer: String?
    private let featureFlagKeyRawValue: String

    public init(
        title: String,
        footer: String? = nil,
        featureFlagKey: FeatureFlagKey,
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase
    ) {
        self.title = title
        self.footer = footer
        self.featureFlagKeyRawValue = featureFlagKey.rawValue
        self.featureFlagsUseCase = featureFlagsUseCase
        super.init()
        self.isEnabled = featureFlagsUseCase.get(
            for: featureFlagKey
        ) ?? false
    }

    public init(
        title: String,
        footer: String? = nil,
        featureFlagKeyRawValue: String,
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase
    ) {
        self.title = title
        self.footer = footer
        self.featureFlagKeyRawValue = featureFlagKeyRawValue
        self.featureFlagsUseCase = featureFlagsUseCase
        super.init()
        self.isEnabled = featureFlagsUseCase.get(
            for: featureFlagKeyRawValue
        ) ?? false
    }

    func toggle() {
        let toggleValue = !isEnabled
        isEnabled = toggleValue
        self.featureFlagsUseCase.set(
            toggleValue,
            for: featureFlagKeyRawValue
        )
    }
}
