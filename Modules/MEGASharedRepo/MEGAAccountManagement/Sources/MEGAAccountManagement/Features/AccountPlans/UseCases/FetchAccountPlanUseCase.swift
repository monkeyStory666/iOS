// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public protocol FetchAccountPlanUseCaseProtocol {
    func fetch(timeout: TimeInterval?) async throws -> AccountPlanTypeEntity
    func fetchAccountDetails(timeout: TimeInterval?) async throws -> AccountDetailsEntity
}

public extension FetchAccountPlanUseCaseProtocol {
    func fetchAccountDetails(timeout: TimeInterval? = nil) async throws -> AccountDetailsEntity {
        try await fetchAccountDetails(timeout: nil)
    }
}

public extension FetchAccountPlanUseCaseProtocol {
    func fetch() async throws -> AccountPlanTypeEntity {
        try await fetch(timeout: nil)
    }

    func fetchAccountDetails() async throws -> AccountDetailsEntity {
        try await fetchAccountDetails(timeout: nil)
    }
}

public struct FetchAccountPlanUseCase<
    Fetcher: RepositoryFetching
>: FetchAccountPlanUseCaseProtocol, @unchecked Sendable where
    Fetcher.RepoData == AccountDetailsEntity,
    Fetcher: Sendable {
    private let fetcher: Fetcher

    public init(fetcher: Fetcher) {
        self.fetcher = fetcher
    }

    public func fetch(timeout: TimeInterval?) async throws -> AccountPlanTypeEntity {
        try await fetchAccountDetails(timeout: timeout).accountPlan?.type ?? .free
    }

    public func fetchAccountDetails(timeout: TimeInterval? = nil) async throws -> AccountDetailsEntity {
        try await fetcher.fetchRemoteWithLocalFallback(timeout: timeout)
    }
}
