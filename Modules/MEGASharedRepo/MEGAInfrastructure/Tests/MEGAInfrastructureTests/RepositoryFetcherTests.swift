// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct RepositoryFetcherTests {
    @Test func fetchLocal_returnsLocalData() {
        let localData = randomDataList
        let mockLocalRepo = LocalRepository(fetch: localData)
        let sut = makeSUT(localRepository: mockLocalRepo)

        #expect(sut.fetchLocal() == localData)
    }

    @Test func fetchRemote_successfully_returnRemoteData_andSavesToLocalStorage() async throws {
        let remoteData = randomDataList
        let mockRemoteRepo = RemoteRepository(fetch: .success(remoteData))
        let mockLocalRepo = LocalRepository()
        let sut = makeSUT(remoteRepository: mockRemoteRepo, localRepository: mockLocalRepo)

        let data = try await sut.fetchRemote()

        #expect(remoteData == data)
        mockLocalRepo.swt.assertActions(shouldBe: [.save(remoteData)])
    }

    @Test func fetchRemote_withError_throwsError() async {
        let mockRemoteRepo = RemoteRepository(fetch: .failure(ErrorInTest()))
        let sut = makeSUT(remoteRepository: mockRemoteRepo)

        do {
            _ = try await sut.fetchRemote()
            Issue.record("Expected error, got none")
        } catch {
            #expect(error is ErrorInTest)
        }
    }

    @Test func fetchLocalWithRemoteFallback_withLocalData_returnsLocalData_withoutFetchingRemoteData() async throws {
        let localData = randomDataList
        let mockLocalRepo = LocalRepository(fetch: localData)
        let mockRemoteRepo = RemoteRepository()
        let sut = makeSUT(remoteRepository: mockRemoteRepo, localRepository: mockLocalRepo)

        let data = try await sut.fetchLocalWithRemoteFallback()

        #expect(data == localData)
        mockRemoteRepo.swt.assertActions(shouldBe: [])
    }

    @Test func fetchLocalWithRemoteFallback_withEmptyLocalData_returnsRemoteData() async throws {
        let remoteData = randomDataList
        let mockLocalRepo = LocalRepository(fetch: [])
        let mockRemoteRepo = RemoteRepository(fetch: .success(remoteData))
        let sut = makeSUT(remoteRepository: mockRemoteRepo, localRepository: mockLocalRepo)

        let data = try await sut.fetchLocalWithRemoteFallback()

        #expect(data == remoteData)
        mockRemoteRepo.swt.assertActions(shouldBe: [.fetch])
    }

    @Test func fetchLocalWithRemoteFallbackWithTimeout_withoutLocalData_shouldFallbackWithTimeout() async throws {
        let expectedTimeout = TimeInterval.random()
        let mockRemoteRepo = RemoteRepository(fetch: .success(randomDataList))
        let sut = makeSUT(
            remoteRepository: mockRemoteRepo,
            localRepository: LocalRepository(fetch: [])
        )

        _ = try await sut.fetchLocalWithRemoteFallback(timeout: expectedTimeout)

        mockRemoteRepo.swt.assertActions(
            shouldBe: [.fetchWithTimeout(expectedTimeout)]
        )
    }

    @Test func fetchRemoteWithLocalFallback_withRemoteData_returnsRemoteData_withoutFetchingLocalData() async throws {
        let remoteData = randomDataList
        let mockLocalRepo = LocalRepository()
        let mockRemoteRepo = RemoteRepository(fetch: .success(remoteData))
        let sut = makeSUT(remoteRepository: mockRemoteRepo, localRepository: mockLocalRepo)

        let data = try await sut.fetchRemoteWithLocalFallback()

        #expect(data == remoteData)
    }

    @Test func fetchRemoteWithLocalFallbackWithTimeout_shouldFetchWithTimeout() async throws {
        let expectedTimeout = TimeInterval.random()
        let mockRemoteRepo = RemoteRepository(fetch: .success(randomDataList))
        let sut = makeSUT(remoteRepository: mockRemoteRepo)

        _ = try await sut.fetchRemoteWithLocalFallback(timeout: expectedTimeout)

        mockRemoteRepo.swt.assertActions(
            shouldBe: [.fetchWithTimeout(expectedTimeout)]
        )
    }

    @Test func fetchRemoteWithLocalFallback_withRemoteError_returnsLocalData() async throws {
        let localData = randomDataList
        let mockLocalRepo = LocalRepository(fetch: localData)
        let mockRemoteRepo = RemoteRepository(fetch: .failure(ErrorInTest()))
        let sut = makeSUT(remoteRepository: mockRemoteRepo, localRepository: mockLocalRepo)

        let data = try await sut.fetchRemoteWithLocalFallback()

        #expect(data == localData)
    }

    @Test func fetchRemoteWithLocalFallback_withRemoteErrorAndEmptyLocal_throwErrorFromRemoteRepository() async throws {
        let mockRemoteRepo = RemoteRepository(fetch: .failure(ErrorInTest()))
        let sut = makeSUT(
            remoteRepository: mockRemoteRepo,
            localRepository: LocalRepository(fetch: nil)
        )

        do {
            _ = try await sut.fetchRemoteWithLocalFallback()
            Issue.record("Expected error, got none")
        } catch {
            #expect(error is ErrorInTest)
        }
    }

    // MARK: - Test Helpers

    private typealias SUT = RepositoryFetcher<
        [String],
        LocalRepository,
        RemoteRepository
    >

    private typealias RemoteRepository = MockRemoteRepository<[String]>
    private typealias LocalRepository = MockLocalRepository<[String]>

    private func makeSUT(
        remoteRepository: RemoteRepository = .init(),
        localRepository: LocalRepository = .init()
    ) -> SUT {
        RepositoryFetcher(
            remoteRepository: remoteRepository,
            localRepository: localRepository
        )
    }

    private var randomData: String { .random() }

    private var randomDataList: [String] {
        [randomData, randomData, randomData]
    }
}

private extension MockRemoteRepository where RemoteData == [String] {
    convenience init(_ fetch: Result<[String], Error> = .success([])) {
        self.init(fetch: fetch)
    }
}
