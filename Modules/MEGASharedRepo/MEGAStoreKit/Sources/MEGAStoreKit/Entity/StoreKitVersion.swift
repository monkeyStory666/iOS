// Copyright © 2024 MEGA Limited. All rights reserved.

public enum StoreKitVersion: String, Codable, CaseIterable {
    case storeKit = "StoreKit 2"
    case legacyStoreKit = "StoreKit 1 (Legacy)"
}

public extension StoreKitVersion {
    static var qaOverriddenStoreKitVersion: StoreKitVersion? {
        DependencyInjection.featureFlagsUseCase.get(for: .storeKitVersion)
    }
}
