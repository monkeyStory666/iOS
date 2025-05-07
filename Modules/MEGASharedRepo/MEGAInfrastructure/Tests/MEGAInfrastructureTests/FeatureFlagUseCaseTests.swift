// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAInfrastructureMocks
import Testing

struct FeatureFlagUseCaseTests {
    @Test func set_shouldCallRepo() {
        let expectedValue = "anyValue"
        let expectedKey = "anyKey"
        let mockRepo = MockFeatureFlagsRepository()
        let sut = makeSUT(repo: mockRepo)

        sut.set(expectedValue, for: expectedKey)

        mockRepo.swt.assertActions(shouldBe: [.setValue(expectedValue, forKey: expectedKey)])
    }

    @Test func get_shouldCallRepo() {
        let expectedValue = "anyValue"
        let expectedKey = "anyKey"
        let mockRepo = MockFeatureFlagsRepository(storage: [expectedKey: expectedValue])
        let sut = makeSUT(repo: mockRepo)

        let result: String? = sut.get(for: expectedKey)

        mockRepo.swt.assertActions(shouldBe: [.getValue(forKey: expectedKey)])
        #expect(result == expectedValue)
    }

    // MARK: - Test Extension FeatureFlagKey

    @Test func set_withFeatureFlagKey_shouldReturnCorrectValue() {
        let expectedValue = Bool.random()
        let expectedKey = FeatureFlagKey.toggleRemoteFlag
        let mockRepo = MockFeatureFlagsRepository()
        let sut = makeSUT(repo: mockRepo)

        sut.set(expectedValue, for: expectedKey)

        mockRepo.swt.assertActions(shouldBe: [.setValue(expectedValue, forKey: expectedKey.rawValue)])
    }

    @Test func get_withFeatureFlagKey_shouldReturnCorrectValue() {
        let expectedValue = Bool.random()
        let expectedKey = FeatureFlagKey.toggleRemoteFlag
        let mockRepo = MockFeatureFlagsRepository(storage: [expectedKey.rawValue: expectedValue])
        let sut = makeSUT(repo: mockRepo)

        let result: Bool? = sut.get(for: expectedKey)

        mockRepo.swt.assertActions(shouldBe: [.getValue(forKey: expectedKey.rawValue)])
        #expect(result == expectedValue)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repo: some FeatureFlagsRepositoryProtocol = MockFeatureFlagsRepository()
    ) -> FeatureFlagsUseCase {
        FeatureFlagsUseCase(repo: repo)
    }
}
