// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAInfrastructure
import MEGAStoreKit
import MEGAUIComponent
import SwiftUI

public final class StoreKitVersionToggleViewModel: NoRouteViewModel {
    let options: [StoreKitVersion?] = [nil] + StoreKitVersion.allCases

    @ViewProperty var storeVersion: StoreKitVersion?

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase) {
        self.featureFlagsUseCase = featureFlagsUseCase
        super.init()
        if let storeVersion: StoreKitVersion = featureFlagsUseCase.get(for: .storeKitVersion) {
            self.storeVersion = storeVersion
        }
    }

    func select(_ version: StoreKitVersion?) {
        self.storeVersion = version
        self.featureFlagsUseCase.set(version, for: .storeKitVersion)
    }
}
