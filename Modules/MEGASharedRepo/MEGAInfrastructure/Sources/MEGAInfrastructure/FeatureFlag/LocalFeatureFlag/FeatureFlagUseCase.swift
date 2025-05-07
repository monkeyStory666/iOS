// Copyright © 2024 MEGA Limited. All rights reserved.

public protocol FeatureFlagsUseCaseProtocol: Sendable {
    func set<T: Encodable>(_ value: T, for key: String)
    func get<T: Decodable>(for key: String) -> T?
}

public extension FeatureFlagsUseCaseProtocol {
    func set<T: Encodable>(_ value: T, for key: FeatureFlagKey) {
        set(value, for: key.rawValue)
    }

    func get<T: Decodable>(for key: FeatureFlagKey) -> T? {
        get(for: key.rawValue)
    }
}

public enum FeatureFlagKey: String, Sendable {
    case sdkEnvironment
    case trackAnalyticsFlag
    case toggleRemoteFlag

    // Store & In-App Purchase
    case simulateStoreError
    case simulateStorePricesChanged
    case simulateSDKPurchaseError
    case storeKitVersion
    case overrideFreeTrialEligibility

    // Feature Toggle
    case freeTrialEligibility
}

public struct FeatureFlagsUseCase: FeatureFlagsUseCaseProtocol {
    private let repo: any FeatureFlagsRepositoryProtocol

    public init(repo: some FeatureFlagsRepositoryProtocol) {
        self.repo = repo
    }

    public func set<T: Encodable>(_ value: T, for key: String) {
        repo.set(value, for: key)
    }

    public func get<T: Decodable>(for key: String) -> T? {
        repo.get(for: key)
    }
}
