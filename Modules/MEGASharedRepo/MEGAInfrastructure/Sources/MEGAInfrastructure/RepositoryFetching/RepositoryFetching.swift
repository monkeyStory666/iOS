// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol RepositoryFetching: Sendable {
    associatedtype RepoData

    func fetchLocalWithRemoteFallback() async throws -> RepoData
    func fetchRemoteWithLocalFallback() async throws -> RepoData
    func fetchRemote() async throws -> RepoData
    func fetchLocalWithRemoteFallback(timeout: TimeInterval?) async throws -> RepoData
    func fetchRemoteWithLocalFallback(timeout: TimeInterval?) async throws -> RepoData
    func fetchRemote(timeout: TimeInterval?) async throws -> RepoData
    func fetchLocal() -> RepoData?
}

public extension RepositoryFetching {
    func fetchLocalWithRemoteFallback() async throws -> RepoData {
        try await fetchLocalWithRemoteFallback(timeout: nil)
    }

    func fetchRemoteWithLocalFallback() async throws -> RepoData {
        try await fetchRemoteWithLocalFallback(timeout: nil)
    }

    func fetchRemote() async throws -> RepoData {
        try await fetchRemote(timeout: nil)
    }
}

public struct RepositoryFetcher<
    RepoData: Codable,
    LocalRepository: LocalDataRepositoryProtocol,
    RemoteRepository: RemoteDataRepositoryProtocol
>: RepositoryFetching, Sendable where
LocalRepository.LocalData == RepoData,
RemoteRepository.RemoteData == RepoData {
    private let remoteRepository: RemoteRepository
    private let localRepository: LocalRepository

    public init(
        remoteRepository: RemoteRepository,
        localRepository: LocalRepository
    ) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
    }

    public func fetchLocalWithRemoteFallback(timeout: TimeInterval?) async throws -> RepoData {
        if let localData = fetchLocal(), (localData as? (any Collection))?.isEmpty != true {
            return localData
        } else if let timeout {
            return try await fetchRemote(timeout: timeout)
        } else {
            return try await fetchRemote()
        }
    }

    public func fetchRemoteWithLocalFallback(timeout: TimeInterval?) async throws -> RepoData {
        do {
            if let timeout {
                return try await fetchRemote(timeout: timeout)
            } else {
                return try await fetchRemote()
            }
        } catch {
            if let localData = fetchLocal() {
                return localData
            } else {
                throw error
            }
        }
    }

    public func fetchRemote(timeout: TimeInterval?) async throws -> RepoData {
        let element = if let timeout {
            try await remoteRepository.fetch(timeout: timeout)
        } else {
            try await remoteRepository.fetch()
        }
        localRepository.save(element)
        return element
    }

    public func fetchLocal() -> RepoData? {
        localRepository.fetch()
    }
}
