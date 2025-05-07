// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

@Suite(.serialized)
struct PasswordReminderUseCaseTests {
    // MARK: - Use Remote Repository

    struct AssertCallRepositoryArgs {
        let atLogout: Bool
        let shouldShowPasswordReminder: Bool
    }
    @Test(arguments: [
        .init(atLogout: true, shouldShowPasswordReminder: true),
        .init(atLogout: true, shouldShowPasswordReminder: false),
        .init(atLogout: false, shouldShowPasswordReminder: true),
        .init(atLogout: false, shouldShowPasswordReminder: false)
    ] as [AssertCallRepositoryArgs])
    func shouldShowPasswordReminder_shouldCallRepository(
        arguments: AssertCallRepositoryArgs
    ) async throws {
        let repository = MockPasswordReminderRepository(
            shouldShowPasswordReminder: arguments.shouldShowPasswordReminder
        )
        let sut = makeSUT(repository: repository, useLocalCache: false)

        let result = try await sut.shouldShowPasswordReminder(
            atLogout: arguments.atLogout
        )

        #expect(
            repository.actions == [.shouldShowPasswordReminder(
                atLogout: arguments.atLogout
            )]
        )
        #expect(result == arguments.shouldShowPasswordReminder)
    }

    @Test func passwordReminderBlocked_shouldCallRepository() async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(repository: repository, useLocalCache: false)

        try await sut.passwordReminderBlocked()

        #expect(repository.actions == [.passwordReminderBlocked])
    }

    @Test func passwordReminderSkipped_shouldCallRepository() async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(repository: repository, useLocalCache: false)

        try await sut.passwordReminderSkipped()

        #expect(repository.actions == [.passwordReminderSkipped])
    }

    @Test func passwordReminderSucceeded_shouldCallRepository() async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(repository: repository, useLocalCache: false)

        try await sut.passwordReminderSucceeded()

        #expect(repository.actions == [.passwordReminderSucceeded])
    }

    // MARK: - Local Cache

    @Test func passwordReminderBlocked_whenUseLocalCache_shouldNotUseSDK() async throws {
        let repository = MockPasswordReminderRepository()
        let mockCache = MockCacheService()
        let sut = makeSUT(
            repository: repository,
            cacheService: mockCache,
            useLocalCache: true
        )

        try await sut.passwordReminderBlocked()

        #expect(repository.actions.isEmpty)
    }

    @Test func passwordReminderSkipped_whenUseLocalCache_shouldNotCallSDK() async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(
            repository: repository,
            useLocalCache: true
        )

        try await sut.passwordReminderSkipped()

        #expect(repository.actions.isEmpty)
    }

    @Test func passwordReminderSucceeded_whenUseLocalCache_shouldNotCallSDK() async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(
            repository: repository,
            useLocalCache: true
        )

        try await sut.passwordReminderSucceeded()

        #expect(repository.actions.isEmpty)
    }

    struct PasswordReminderBlockedUseLocalCacheArgs {
        let accountResult: Result<AccountEntity, Error>
        let cacheResult: Result<(any Decodable)?, Error>
        let expectedCacheActions: [MockCacheService.Action]
        let comments: Comment?
    }

    @Test(arguments: [
        .init(
            accountResult: .failure(ErrorInTest()),
            cacheResult: .failure(ErrorInTest()),
            expectedCacheActions: [],
            comments: "Expected to not call any action when fetch account failed"
        ),
        .init(
            accountResult: .failure(ErrorInTest()),
            cacheResult: .success([randomEmail(): true]),
            expectedCacheActions: [],
            comments: "Expected to not call any action when fetch account failed"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .failure(ErrorInTest()),
            expectedCacheActions: [
                .fetch(PasswordReminderUseCase.cacheKeyString),
                .save(.init(
                    object: [currentUserEmail: false],
                    key: PasswordReminderUseCase.cacheKeyString
                ))
            ],
            comments: "Expected to create new cache and save it when fetch cache failed"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .success(nil),
            expectedCacheActions: [
                .fetch(PasswordReminderUseCase.cacheKeyString),
                .save(.init(
                    object: [currentUserEmail: false],
                    key: PasswordReminderUseCase.cacheKeyString
                ))
            ],
            comments: "Expected to create new cache and save it when fetch cache is nil"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .success([currentUserEmail: true]),
            expectedCacheActions: [
                .fetch(PasswordReminderUseCase.cacheKeyString),
                .save(.init(
                    object: [currentUserEmail: false],
                    key: PasswordReminderUseCase.cacheKeyString
                ))
            ],
            comments: "Expected to update cache and save it when fetch cache is not nil"
        )
    ] as [PasswordReminderBlockedUseLocalCacheArgs])
    func passwordReminderBlocked_whenUseLocalCache(
        arguments: PasswordReminderBlockedUseLocalCacheArgs
    ) async throws {
        let cacheService = MockCacheService(fetch: arguments.cacheResult)
        let sut = makeSUT(
            cacheService: cacheService,
            accountUseCase: MockFetchAccountUseCase(fetchAccount: arguments.accountResult),
            useLocalCache: true
        )

        try await sut.passwordReminderBlocked()

        #expect(cacheService.actions == arguments.expectedCacheActions, arguments.comments)
    }

    @Test func passwordReminderBlocked_whenUseLocalCache_shouldSaveToCache() async throws {
        let cacheService = MockCacheService(fetch: .success([anotherUserEmail: false]))
        let sut = makeSUT(
            cacheService: cacheService,
            accountUseCase: MockFetchAccountUseCase(fetchAccount: .success(.sample(email: currentUserEmail))),
            useLocalCache: true
        )

        try await sut.passwordReminderBlocked()

        guard let lastAction = cacheService.actions.last else {
            Issue.record("Cache service should have made an action")
            return
        }

        guard case .save(let saveParam) = lastAction else {
            Issue.record("Last action should be saving to cache")
            return
        }

        let saveObject = try #require(saveParam.object as? [String: Bool])
        #expect(saveObject.count == 2)
        #expect(saveObject[currentUserEmail] == false)
        #expect(saveObject[anotherUserEmail] == false)
    }

    struct ShouldShowPasswordReminderUseLocalCacheArgs {
        let accountResult: Result<AccountEntity, Error>
        let cacheResult: Result<(any Decodable)?, Error>
        let shouldShowPasswordReminder: Bool
        let comments: Comment?
    }

    @Test(arguments: [
        .init(
            accountResult: .failure(ErrorInTest()),
            cacheResult: .failure(ErrorInTest()),
            shouldShowPasswordReminder: true,
            comments: "Expected to return true when fetch account failed"
        ),
        .init(
            accountResult: .failure(ErrorInTest()),
            cacheResult: .success([randomEmail(): true]),
            shouldShowPasswordReminder: true,
            comments: "Expected to return true when fetch account failed"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .failure(ErrorInTest()),
            shouldShowPasswordReminder: true,
            comments: "Expected to return true when fetch cache failed"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .success(nil),
            shouldShowPasswordReminder: true,
            comments: "Expected to return true when fetch cache is nil"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .success([currentUserEmail: false]),
            shouldShowPasswordReminder: false,
            comments: "Expected to return cache value when fetch cache is not nil"
        ),
        .init(
            accountResult: .success(.sample(email: currentUserEmail)),
            cacheResult: .success([anotherUserEmail: false]),
            shouldShowPasswordReminder: true,
            comments: "Expected to return true when fetch cache does not contain current user"
        )
    ] as [ShouldShowPasswordReminderUseLocalCacheArgs])
    func shouldShowPasswordReminder_whenUseLocalCache(
        arguments: ShouldShowPasswordReminderUseLocalCacheArgs
    ) async throws {
        let repository = MockPasswordReminderRepository()
        let sut = makeSUT(
            repository: repository,
            cacheService: MockCacheService(fetch: arguments.cacheResult),
            accountUseCase: MockFetchAccountUseCase(fetchAccount: arguments.accountResult),
            useLocalCache: true
        )

        #expect(
            try await sut.shouldShowPasswordReminder(
                atLogout: .random()
            ) == arguments.shouldShowPasswordReminder
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repository: some PasswordReminderRepositoryProtocol =
            MockPasswordReminderRepository(),
        cacheService: some CacheServiceProtocol = MockCacheService(),
        accountUseCase: some FetchAccountUseCaseProtocol = MockFetchAccountUseCase(),
        useLocalCache: Bool = false
    ) -> PasswordReminderUseCase {
        PasswordReminderUseCase(
            repository: repository,
            cacheService: cacheService,
            accountUseCase: accountUseCase,
            useLocalCache: useLocalCache
        )
    }
}

private var anotherUserEmail: String {
    "test-another@mega.co.nz"
}

private var currentUserEmail: String {
    "test-email@mega.co.nz"
}

private func randomEmail() -> String {
    .random(withPrefix: "email")
}
