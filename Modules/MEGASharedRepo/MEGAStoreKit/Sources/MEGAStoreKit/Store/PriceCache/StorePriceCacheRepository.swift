// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public struct StorePriceCacheRepository: StorePriceCacheRepositoryProtocol {
    private let cacheService: CacheServiceProtocol
    private let key = "storePriceCacheKey"

    public init(cacheService: CacheServiceProtocol) {
        self.cacheService = cacheService
    }

    public func save(price: String, for identifier: String) {
        var prices = getPrices()
        prices[identifier] = price
        try? cacheService.save(prices, for: key)
    }

    public func getPrice(for identifier: String) -> String? {
        getPrices()[identifier]
    }

    public func getPrices() -> [String: String] {
        (try? cacheService.fetch(for: key)) ?? [:]
    }
}
