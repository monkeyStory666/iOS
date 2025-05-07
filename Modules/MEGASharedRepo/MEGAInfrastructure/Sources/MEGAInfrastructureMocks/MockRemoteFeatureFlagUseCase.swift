// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockRemoteFeatureFlagUseCase:
    MockObject<MockRemoteFeatureFlagUseCase.Action>,
    RemoteFeatureFlagUseCaseProtocol {
    public enum Action: Equatable {
        case get(key: String)
    }

    public var _get: RemoteFeatureFlagState

    public init(get: RemoteFeatureFlagState = .disabled) {
        self._get = get
    }

    public func get(for key: String) async -> RemoteFeatureFlagState {
        actions.append(.get(key: key))
        return _get
    }
}
