// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGAStoreKit
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct StorePriceCacheRepositoryTests {
    @Test func getPrices() {
        let expectedKey = String.random()
        let expectedPrice = String.random()
        let mockCacheService = MockCacheService(fetch: .success([expectedKey: expectedPrice]))
        let sut = makeSUT(cacheService: mockCacheService)

        let result = sut.getPrices()

        #expect(result == [expectedKey: expectedPrice])
        mockCacheService.swt.assertActions(shouldBe: [.fetch("storePriceCacheKey")])
    }

    @Test func getPriceForIdentifier() {
        let expectedKey = String.random()
        let expectedPrice = String.random()
        let mockCacheService = MockCacheService(fetch: .success([expectedKey: expectedPrice]))
        let sut = makeSUT(cacheService: mockCacheService)

        let result = sut.getPrice(for: expectedKey)

        #expect(result == expectedPrice)
        mockCacheService.swt.assertActions(shouldBe: [.fetch("storePriceCacheKey")])
    }

    @Test func savePrice() {
        let expectedKey = String.random()
        let expectedPrice = String.random()
        let mockCacheService = MockCacheService()
        let sut = makeSUT(cacheService: mockCacheService)

        sut.save(price: expectedPrice, for: expectedKey)

        mockCacheService.swt.assert(
            .save(.init(object: [expectedKey: expectedPrice], key: "storePriceCacheKey")),
            isCalled: .once
        )
    }

    private func makeSUT(
        cacheService: CacheServiceProtocol = MockCacheService()
    ) -> StorePriceCacheRepository {
        StorePriceCacheRepository(cacheService: cacheService)
    }
}
