// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

public final class MockRemoteRepository<RemoteData>:
    MockObject<MockRemoteRepository.Action>,
    RemoteDataRepositoryProtocol {
    public enum Action: Equatable {
        case fetch
        case fetchWithTimeout(TimeInterval)
    }

    public var _fetch: Result<RemoteData, Error>

    public init(fetch: Result<RemoteData, Error>) {
        self._fetch = fetch
    }

    public func fetch() async throws -> RemoteData {
        actions.append(.fetch)
        return try _fetch.get()
    }

    public func fetch(timeout: TimeInterval) async throws -> RemoteData {
        actions.append(.fetchWithTimeout(timeout))
        return try _fetch.get()
    }
}
