// Copyright © 2024 MEGA Limited. All rights reserved.

public protocol FeatureFlagsRepositoryProtocol: Sendable {
    func set<T: Encodable>(_ value: T, for key: String)
    func get<T: Decodable>(for key: String) -> T?
}
