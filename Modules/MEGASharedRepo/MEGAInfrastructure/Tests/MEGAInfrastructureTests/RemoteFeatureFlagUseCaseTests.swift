// Copyright © 2023 MEGA Limited. All rights reserved.

import Testing
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest

struct RemoteFeatureFlagUseCaseTests {
    @Test func get_shouldGetFromRepository() async {
        let mockRepo = MockRemoteFeatureFlagRepository()
        let sut = makeSUT(repo: mockRepo)
        let randomKey = String.random()

        _ = await sut.get(for: randomKey)

        mockRepo.assertActions(shouldBe: [.get(key: randomKey)])
    }

    @Test func get_whenRepositoryReturnsZeroOrLower_shouldReturnDisabled() async {
        let sut = makeSUT(
            repo: MockRemoteFeatureFlagRepository(
                get: .success(.random(in: Int.min...0))
            )
        )

        let result = await sut.get(for: "any")

        #expect(result == .disabled)
    }

    @Test func get_whenRepositoryReturnsGreaterThanZero_shouldReturnEnabled() async {
        let randomValue = Int.random(in: 1...Int.max)
        let sut = makeSUT(
            repo: MockRemoteFeatureFlagRepository(
                get: .success(randomValue)
            )
        )

        let result = await sut.get(for: "any")

        #expect(result == .enabled(value: randomValue))
    }

    @Test func get_whenRepositoryThrowsError_shouldReturnDisabled() async {
        let sut = makeSUT(
            repo: MockRemoteFeatureFlagRepository(
                get: .failure(ErrorInTest())
            )
        )

        let result = await sut.get(for: "any")

        #expect(result == .disabled)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repo: some RemoteFeatureFlagRepositoryProtocol = MockRemoteFeatureFlagRepository()
    ) -> RemoteFeatureFlagUseCase {
        RemoteFeatureFlagUseCase(repo: repo)
    }
}

