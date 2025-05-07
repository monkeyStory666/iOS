// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

open class MockFetcher<FetchedData>: MockObject<MockFetcher.Action>, RepositoryFetching {
    public enum Action: Equatable {
        case fetchLocalWithRemoteFallback(TimeInterval?)
        case fetchRemoteWithLocalFallback(TimeInterval?)
        case fetchRemote(TimeInterval?)
        case fetchLocal
    }

    public var _fetchLocalWithRemoteFallback: Result<FetchedData, Error>
    public var _fetchRemoteWithLocalFallback: Result<FetchedData, Error>
    public var _fetchRemote: Result<FetchedData, Error>
    public var _fetchLocal: FetchedData?

    public init(
        _fetchLocalWithRemoteFallback: Result<FetchedData, Error>,
        _fetchRemoteWithLocalFallback: Result<FetchedData, Error>,
        _fetchRemote: Result<FetchedData, Error>,
        _fetchLocal: FetchedData?
    ) {
        self._fetchLocalWithRemoteFallback = _fetchLocalWithRemoteFallback
        self._fetchRemoteWithLocalFallback = _fetchRemoteWithLocalFallback
        self._fetchRemote = _fetchRemote
        self._fetchLocal = _fetchLocal
    }

    public func fetchLocalWithRemoteFallback(timeout: TimeInterval?) async throws -> FetchedData {
        actions.append(.fetchLocalWithRemoteFallback(timeout))
        return try _fetchLocalWithRemoteFallback.get()
    }

    public func fetchRemoteWithLocalFallback(timeout: TimeInterval?) async throws -> FetchedData {
        actions.append(.fetchRemoteWithLocalFallback(timeout))
        return try _fetchRemoteWithLocalFallback.get()
    }

    public func fetchRemote(timeout: TimeInterval?) async throws -> FetchedData {
        actions.append(.fetchRemote(timeout))
        return try _fetchRemote.get()
    }

    public func fetchLocal() -> FetchedData? {
        actions.append(.fetchLocal)
        return _fetchLocal
    }
}
