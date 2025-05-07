// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public protocol FetchAccountUseCaseProtocol {
    func fetchAccount(timeout: TimeInterval?) async throws -> AccountEntity
    func fetchRefreshedAccount(timeout: TimeInterval?) async throws -> AccountEntity
}

public extension FetchAccountUseCaseProtocol {
    func fetchAccount() async throws -> AccountEntity {
        try await fetchAccount(timeout: nil)
    }

    func fetchRefreshedAccount() async throws -> AccountEntity {
        try await fetchRefreshedAccount(timeout: nil)
    }
}

public struct FetchAccountUseCase<
    Fetcher: RepositoryFetching
>: FetchAccountUseCaseProtocol where Fetcher.RepoData == AccountEntity {
    public enum Error: Swift.Error {
        case notFound
    }

    private let fetcher: Fetcher

    public init(fetcher: Fetcher) {
        self.fetcher = fetcher
    }

    public func fetchAccount(timeout: TimeInterval?) async throws -> AccountEntity {
        try await fetcher.fetchLocalWithRemoteFallback(timeout: timeout)
    }

    public func fetchRefreshedAccount(timeout: TimeInterval?) async throws -> AccountEntity {
        try await fetcher.fetchRemoteWithLocalFallback(timeout: timeout)
    }
}
