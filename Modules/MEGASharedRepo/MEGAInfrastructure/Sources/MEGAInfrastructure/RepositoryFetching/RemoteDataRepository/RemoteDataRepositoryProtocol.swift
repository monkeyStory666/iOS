// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol RemoteDataRepositoryProtocol: Sendable {
    associatedtype RemoteData

    func fetch() async throws -> RemoteData
    func fetch(timeout: TimeInterval) async throws -> RemoteData
}

public enum RemoteDataRepositoryErrorEntity: Error, Sendable {
    case generic
    case dataNotFound
}
