// Copyright © 2024 MEGA Limited. All rights reserved.

public final class FeatureFlagsRepository: FeatureFlagsRepositoryProtocol {
    private let cacheService: CacheServiceProtocol

    public init(cacheService: CacheServiceProtocol) {
        self.cacheService = cacheService
    }

    public func set<T: Encodable>(_ value: T, for key: String) {
        try? cacheService.save(value, for: key)
    }

    public func get<T: Decodable>(for key: String) -> T? {
        try? cacheService.fetch(for: key)
    }
}
