// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement
import MEGATest

public final class MockFetchAccountPlanUseCase:
    MockObject<MockFetchAccountPlanUseCase.Action>,
    FetchAccountPlanUseCaseProtocol {
    public enum Action: Equatable {
        case fetch(_ timeout: TimeInterval?)
        case fetchAccountDetails
    }

    public var _fetch: Result<AccountPlanTypeEntity, Error>
    public var _fetchAccountDetails: Result<AccountDetailsEntity, Error>

    public init(
        fetch: Result<AccountPlanTypeEntity, Error> = .success(.free),
        fetchAccountDetails: Result<AccountDetailsEntity, Error> = .success(.sample())
    ) {
        self._fetch = fetch
        self._fetchAccountDetails = fetchAccountDetails
    }

    public func fetch(timeout: TimeInterval?) async throws -> AccountPlanTypeEntity {
        actions.append(.fetch(timeout))
        return try _fetch.get()
    }

    public func fetchAccountDetails(timeout: TimeInterval?) async throws -> AccountDetailsEntity {
        actions.append(.fetchAccountDetails)

        return try _fetchAccountDetails.get()
    }
}
