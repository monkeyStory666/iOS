// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import MEGAWhatsNew
import Testing

struct AppVersionUseCaseTests {
    static private var currentAppVersion: String {
        "1.1.0"
    }

    static private var currentUserEmail: String {
        "test-email@mega.co.nz"
    }

    static private var randomVersion: String {
        .random(withPrefix: "version")
    }

    static private func randomEmail() -> String {
        .random(withPrefix: "email")
    }

    @Test func shouldDisplayWhatsNew_whenFetchAccountError() async {
        let result: AppVersionPersistanceEntity? = [:]
        let sut = makeSUT(
            cacheService: MockCacheService(fetch: .success(result)),
            accountUseCase: MockFetchAccountUseCase(
                fetchAccount: .failure(ErrorInTest())
            )
        )

        #expect(await sut.shouldDisplayWhatsNew(for: AppVersionUseCaseTests.randomVersion))
    }

    @Test(arguments: [
        nil,
        [:]
    ] as [AppVersionPersistanceEntity?])
    func shouldDisplayWhatsNew_whenCacheNil_orEmpty(
        cacheFetchResult: AppVersionPersistanceEntity?
    ) async {
        let sut = makeSUT(cacheService: MockCacheService(
            fetch: .success(cacheFetchResult)
        ))

        #expect(await sut.shouldDisplayWhatsNew(for: AppVersionUseCaseTests.randomVersion))
    }

    @Test(arguments: [[
        randomEmail(): [randomVersion],
        randomEmail(): [randomVersion, randomVersion]
    ]] as [AppVersionPersistanceEntity?])
    func shouldDisplayWhatsNew_whenCacheDoesNotContainCurrentUserEmail(
        cacheFetchResult: AppVersionPersistanceEntity?
    ) async {
        let sut = makeSUT(cacheService: MockCacheService(
            fetch: .success(cacheFetchResult)
        ))

        #expect(await sut.shouldDisplayWhatsNew(for: AppVersionUseCaseTests.randomVersion))
    }

    @Test(arguments: [[
        currentUserEmail: [randomVersion],
        randomEmail(): [randomVersion, randomVersion]
    ]] as [AppVersionPersistanceEntity?])
    func shouldDisplayWhatsNew_whenCurrentUserCacheDoesNotContainCurrentAppVersion(
        cacheFetchResult: AppVersionPersistanceEntity?
    ) async {
        let sut = makeSUT(cacheService: MockCacheService(
            fetch: .success(cacheFetchResult)
        ))

        #expect(await sut.shouldDisplayWhatsNew(for: AppVersionUseCaseTests.currentAppVersion))
    }

    @Test func shouldNotDisplayWhatsNew_whenCurrentUserCacheContainsCurrentAppVersion() async {
        let sut = makeSUT(cacheService: MockCacheService(
            fetch: .success([AppVersionUseCaseTests.currentUserEmail: [AppVersionUseCaseTests.currentAppVersion]])
        ))

        #expect(await sut.shouldDisplayWhatsNew(for: AppVersionUseCaseTests.currentAppVersion) == false)
    }

    @Test func storeWhatsNewDisplayed_whenFetchAccountFail_shouldNotStoreVersion() async {
        let mockCacheService = MockCacheService()
        let sut = makeSUT(
            cacheService: mockCacheService,
            accountUseCase: MockFetchAccountUseCase(
                fetchAccount: .failure(ErrorInTest())
            )
        )

        await sut.storeWhatsNewDisplayed(for: AppVersionUseCaseTests.randomVersion)

        #expect(mockCacheService.actions.isEmpty)
    }

    @Test func storeWhatsNewDisplayed_whenCacheEmpty_shouldSaveNewCache() async {
        let mockCacheService = MockCacheService()
        let sut = makeSUT(cacheService: mockCacheService)

        await sut.storeWhatsNewDisplayed(for: AppVersionUseCaseTests.currentAppVersion)

        #expect(mockCacheService.actions == [
            .fetch(AppVersionPersistanceUseCase.key),
            .save(.init(object: [
                AppVersionUseCaseTests.currentUserEmail: [AppVersionUseCaseTests.currentAppVersion]
            ], key: AppVersionPersistanceUseCase.key))
        ])
    }

    @Test func storeWhatsNewDisplayed_whenCacheExistsForOtherUser_shouldUpdateCache() async {
        let currentCache = [AppVersionUseCaseTests.randomEmail(): [AppVersionUseCaseTests.randomVersion]]
        let expectedCache = {
            var newCache = currentCache
            newCache[AppVersionUseCaseTests.currentUserEmail] = [AppVersionUseCaseTests.currentAppVersion]
            return newCache
        }()
        let mockCacheService = MockCacheService(
            fetch: .success(currentCache)
        )
        let sut = makeSUT(cacheService: mockCacheService)

        await sut.storeWhatsNewDisplayed(for: AppVersionUseCaseTests.currentAppVersion)

        #expect(mockCacheService.actions == [
            .fetch(AppVersionPersistanceUseCase.key),
            .save(.init(
                object: expectedCache,
                key: AppVersionPersistanceUseCase.key
            ))
        ])
    }

    @Test func storeWhatsNewDisplayed_whenCacheExistsForCurrentUser_shouldUpdateCache() async {
        let existingVersion = AppVersionUseCaseTests.randomVersion
        let currentCache = [AppVersionUseCaseTests.currentUserEmail: [existingVersion]]
        let expectedCache = {
            var newCache = currentCache
            newCache[AppVersionUseCaseTests.currentUserEmail] = [existingVersion, AppVersionUseCaseTests.currentAppVersion]
            return newCache
        }()
        let mockCacheService = MockCacheService(
            fetch: .success(currentCache)
        )
        let sut = makeSUT(cacheService: mockCacheService)

        await sut.storeWhatsNewDisplayed(for: AppVersionUseCaseTests.currentAppVersion)

        #expect(mockCacheService.actions == [
            .fetch(AppVersionPersistanceUseCase.key),
            .save(.init(
                object: expectedCache,
                key: AppVersionPersistanceUseCase.key
            ))
        ])
    }

    private func makeSUT(
        cacheService: some CacheServiceProtocol = MockCacheService(),
        accountUseCase: some FetchAccountUseCaseProtocol = MockFetchAccountUseCase(
            fetchAccount: .success(.sample(email: currentUserEmail))
        )
    ) -> some AppVersionPersistanceUseCaseProtocol {
        AppVersionPersistanceUseCase(
            cacheService: cacheService,
            accountUseCase: accountUseCase
        )
    }
}
