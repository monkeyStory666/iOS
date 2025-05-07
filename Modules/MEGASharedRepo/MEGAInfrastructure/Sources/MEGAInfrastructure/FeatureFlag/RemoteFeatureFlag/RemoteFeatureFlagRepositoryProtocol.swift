// Copyright © 2024 MEGA Limited. All rights reserved.

public protocol RemoteFeatureFlagRepositoryProtocol {
    func get(for key: String) async throws -> Int
}

