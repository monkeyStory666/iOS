// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct LocalDataRepositoryTests {
    private let expectedKey = "expectedKey"

    @Test func save_thenFetch_returnsSavedData() {
        let mockCacheService = MockCacheService()
        let sut = makeSUT(cacheService: mockCacheService)
        let data = ["CA", "CA-EAST", "FR", "ES", "BE", "LU"]

        sut.save(data)

        mockCacheService.swt.assertActions(shouldBe: [.save(.init(object: data, key: expectedKey))])
    }

    @Test func fetch_shouldFetchWithExpectedKey() {
        let mockCacheService = MockCacheService()

        _ = makeSUT(cacheService: mockCacheService).fetch()

        mockCacheService.swt.assertActions(shouldBe: [.fetch(expectedKey)])
    }

    @Test func fetch_withCache_returnCache() {
        let mockCacheService = MockCacheService(fetch: .success(["cache", "data"]))
        let sut = makeSUT(cacheService: mockCacheService)

        #expect(sut.fetch() == ["cache", "data"])
    }

    @Test func fetch_withCacheServiceError_returnNil() {
        let mockCacheService = MockCacheService(fetch: .failure(ErrorInTest()))
        let sut = makeSUT(cacheService: mockCacheService)

        #expect(sut.fetch() == nil)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        cacheService: CacheServiceProtocol = MockCacheService()
    ) -> LocalDataRepository<[String]> {
        LocalDataRepository<[String]>(
            key: expectedKey,
            cacheService: cacheService
        )
    }
}
