// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct FetchAccountPlanUseCaseTests {
    @Test func fetch_shouldFetchFromRepository() async throws {
        let mockRepo = MockPlanFetcher(
            fetchRemoteWithLocalFallback: .success(.sample(plans: [.sample(type: .proI)]))
        )
        let sut = makeSUT(repository: mockRepo)

        let fetchedAccountPlan = try await sut.fetch()

        #expect(fetchedAccountPlan == .proI)
        mockRepo.swt.assertActions(shouldBe: [.fetchRemoteWithLocalFallback(nil)])
    }

    @Test func fetch_withTimeout_shouldFetchFromRepository_withTimeout() async throws {
        let randomTimeout = TimeInterval.random()
        let mockRepo = MockPlanFetcher(
            fetchRemoteWithLocalFallback: .success(.sample(plans: [.sample(type: .business)]))
        )
        let sut = makeSUT(repository: mockRepo)

        let fetchedAccountPlan = try await sut.fetch(timeout: randomTimeout)

        #expect(fetchedAccountPlan == .business)
        mockRepo.swt.assertActions(shouldBe: [.fetchRemoteWithLocalFallback(randomTimeout)])
    }

    private typealias MockPlanFetcher = MockFetcher<AccountDetailsEntity>

    private func makeSUT(
        repository: MockPlanFetcher = MockPlanFetcher()
    ) -> FetchAccountPlanUseCase<MockPlanFetcher> {
        FetchAccountPlanUseCase(fetcher: repository)
    }
}

private extension MockFetcher where FetchedData == AccountDetailsEntity {
    convenience init(
        fetchLocalWithRemoteFallback: Result<AccountDetailsEntity, Error> = .success(.sample()),
        fetchRemoteWithLocalFallback: Result<AccountDetailsEntity, Error> = .success(.sample()),
        fetchRemote: Result<AccountDetailsEntity, Error> = .success(.sample()),
        fetchLocal: AccountDetailsEntity? = nil
    ) {
        self.init(
            _fetchLocalWithRemoteFallback: fetchLocalWithRemoteFallback,
            _fetchRemoteWithLocalFallback: fetchRemoteWithLocalFallback,
            _fetchRemote: fetchRemote,
            _fetchLocal: fetchLocal
        )
    }
}
