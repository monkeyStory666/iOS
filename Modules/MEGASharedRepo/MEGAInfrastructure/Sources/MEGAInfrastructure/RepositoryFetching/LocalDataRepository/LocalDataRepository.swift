// Copyright © 2024 MEGA Limited. All rights reserved.

public struct LocalDataRepository<Data: Codable>: LocalDataRepositoryProtocol {
    private let cacheService: CacheServiceProtocol
    private let key: String

    public init(
        key: String,
        cacheService: CacheServiceProtocol
    ) {
        self.key = key
        self.cacheService = cacheService
    }

    public func save(_ prefixes: Data) {
        try? cacheService.save(prefixes, for: key)
    }

    public func fetch() -> Data? {
        return (try? cacheService.fetch(for: key))
    }
}
