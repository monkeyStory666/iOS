// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockLocalRepository<LocalData: Codable & Equatable>:
    MockObject<MockLocalRepository.Action>,
    LocalDataRepositoryProtocol {
    public enum Action: Equatable {
        case save(LocalData)
        case fetch
    }

    public var _fetch: LocalData?

    public init(fetch: LocalData? = nil) {
        self._fetch = fetch
    }

    public func save(_ prefixes: LocalData) {
        actions.append(.save(prefixes))
    }

    public func fetch() -> LocalData? {
        actions.append(.fetch)
        return _fetch
    }
}
