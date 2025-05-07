// Copyright © 2024 MEGA Limited. All rights reserved.

public protocol RemoteFeatureFlagUseCaseProtocol {
    func get(for key: String) async -> RemoteFeatureFlagState
}

public struct RemoteFeatureFlagUseCase: RemoteFeatureFlagUseCaseProtocol {
    private let repo: any RemoteFeatureFlagRepositoryProtocol

    public init(repo: some RemoteFeatureFlagRepositoryProtocol) {
        self.repo = repo
    }

    public func get(for key: String) async -> RemoteFeatureFlagState {
        do {
            let value = try await repo.get(for: key)

            switch value {
            case ...0:
                return .disabled
            default:
                return .enabled(value: value)
            }
        } catch {
            return .disabled
        }
    }
}
