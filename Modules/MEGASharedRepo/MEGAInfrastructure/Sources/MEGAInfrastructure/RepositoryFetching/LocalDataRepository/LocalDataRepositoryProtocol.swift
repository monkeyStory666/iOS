// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol LocalDataRepositoryProtocol: Sendable {
    associatedtype LocalData: Codable

    func save(_ element: LocalData)
    func fetch() -> LocalData?
}
