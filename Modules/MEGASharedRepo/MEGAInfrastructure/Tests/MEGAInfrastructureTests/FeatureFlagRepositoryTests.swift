// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAInfrastructureMocks
import Testing

struct FeatureFlagsRepositoryTests {
    @Test func featureFlagPersistance_shouldBePersistedCorrectly() {
        let cacheService = MockCacheService()
        let sut = makeSUT(cacheService: cacheService)
        sut.set("testType", for: "testFeatureFlagKey")
        #expect(
            cacheService.actions == [
                .save(.init(object: "testType", key: "testFeatureFlagKey"))
            ]
        )
    }

    @Test func featureFlagFetching_shouldBeFetchedCorrectly() {
        let cacheService = MockCacheService(fetch: .success("testType"))
        let sut = makeSUT(cacheService: cacheService)
        let result: String? = sut.get(for: "testFeatureFlagKey")

        #expect(
            cacheService.actions == [
                .fetch("testFeatureFlagKey")
            ]
        )
        #expect(result == "testType")
    }

    private func makeSUT(
        cacheService: CacheServiceProtocol = MockCacheService()
    ) -> some FeatureFlagsRepositoryProtocol {
        FeatureFlagsRepository(cacheService: cacheService)
    }
}
