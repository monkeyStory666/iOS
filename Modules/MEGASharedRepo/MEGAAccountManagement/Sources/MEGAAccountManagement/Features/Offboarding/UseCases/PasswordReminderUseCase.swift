// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure

public protocol PasswordReminderUseCaseProtocol {
    func shouldShowPasswordReminder(atLogout: Bool) async throws -> Bool
    func passwordReminderBlocked() async throws
    func passwordReminderSkipped() async throws
    func passwordReminderSucceeded() async throws
}

public struct PasswordReminderUseCase: PasswordReminderUseCaseProtocol {
    public static let cacheKeyString = "passwordReminderV2"

    private let repository: any PasswordReminderRepositoryProtocol
    private let cacheService: any CacheServiceProtocol
    private let accountUseCase: any FetchAccountUseCaseProtocol
    private let useLocalCache: Bool

    public init(
        repository: some PasswordReminderRepositoryProtocol,
        cacheService: some CacheServiceProtocol,
        accountUseCase: some FetchAccountUseCaseProtocol,
        useLocalCache: Bool = false
    ) {
        self.repository = repository
        self.cacheService = cacheService
        self.accountUseCase = accountUseCase
        self.useLocalCache = useLocalCache
    }

    public func shouldShowPasswordReminder(atLogout: Bool) async throws -> Bool {
        guard useLocalCache else {
            return try await repository.shouldShowPasswordReminder(atLogout: atLogout)
        }

        guard let email = try? await accountUseCase.fetchAccount().email else {
            return defaultShouldShowPasswordReminder
        }

        guard let cache: [String: Bool] = try? cacheService.fetch(for: Self.cacheKeyString) else {
            return defaultShouldShowPasswordReminder
        }

        return cache[email] ?? defaultShouldShowPasswordReminder
    }

    public func passwordReminderBlocked() async throws {
        guard useLocalCache else { return try await repository.passwordReminderBlocked() }

        guard let email = try? await accountUseCase.fetchAccount().email else { return }

        guard let cache: [String: Bool] = try? cacheService.fetch(for: Self.cacheKeyString) else {
            try cacheService.save([email: false], for: Self.cacheKeyString)
            return
        }

        var newCache = cache
        newCache[email] = false
        try cacheService.save(newCache, for: Self.cacheKeyString)
    }

    public func passwordReminderSkipped() async throws {
        guard !useLocalCache else { return }

        try await repository.passwordReminderSkipped()
    }

    public func passwordReminderSucceeded() async throws {
        guard !useLocalCache else { return }

        try await repository.passwordReminderSucceeded()
    }

    private var defaultShouldShowPasswordReminder: Bool { true }
}
