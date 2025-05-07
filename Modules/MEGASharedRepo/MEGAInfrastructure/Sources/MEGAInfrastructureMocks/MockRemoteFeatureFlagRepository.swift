// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockRemoteFeatureFlagRepository:
    MockObject<MockRemoteFeatureFlagRepository.Action>,
    RemoteFeatureFlagRepositoryProtocol {
    public enum Action: Equatable {
        case get(key: String)
    }

    public var _get: Result<Int, Error>

    public init(get: Result<Int, Error> = .success(0)) {
        self._get = get
    }

    public func get(for key: String) async throws -> Int {
        actions.append(.get(key: key))
        return try _get.get()
    }
}
