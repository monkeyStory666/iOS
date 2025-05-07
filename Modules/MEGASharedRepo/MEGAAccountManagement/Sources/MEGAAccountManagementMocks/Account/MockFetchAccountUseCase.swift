// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement
import MEGATest

public final class MockFetchAccountUseCase:
    MockObject<MockFetchAccountUseCase.Action>,
    FetchAccountUseCaseProtocol {
    public enum Action: Equatable {
        case fetchAccount(_ timeout: TimeInterval?)
        case fetchRefreshedAccount(_ timeout: TimeInterval?)
    }

    public var _fetchAccount: Result<AccountEntity, Error>
    public var _fetchRefreshedAccount: Result<AccountEntity, Error>

    public init(
        fetchAccount: Result<AccountEntity, Error> = .success(.dummy),
        fetchRefreshedAccount: Result<AccountEntity, Error> = .success(.dummy)
    ) {
        self._fetchAccount = fetchAccount
        self._fetchRefreshedAccount = fetchRefreshedAccount
    }

    public func fetchAccount(timeout: TimeInterval?) async throws -> AccountEntity {
        actions.append(.fetchAccount(timeout))
        return try _fetchAccount.get()
    }

    public func fetchRefreshedAccount(timeout: TimeInterval?) async throws -> AccountEntity {
        actions.append(.fetchRefreshedAccount(timeout))
        return try _fetchRefreshedAccount.get()
    }
}
