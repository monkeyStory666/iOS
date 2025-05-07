// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAInfrastructure

public protocol AppVersionPersistanceUseCaseProtocol {
    func shouldDisplayWhatsNew(for version: String) async -> Bool
    func storeWhatsNewDisplayed(for version: String) async
}

public typealias AppVersionPersistanceEntity = [String: [String]]

public struct AppVersionPersistanceUseCase: AppVersionPersistanceUseCaseProtocol {
    public static let key = "appVersionWhatsNewCacheKeyV2"

    private let cacheService: CacheServiceProtocol
    private let accountUseCase: any FetchAccountUseCaseProtocol

    public init(
        cacheService: CacheServiceProtocol,
        accountUseCase: some FetchAccountUseCaseProtocol
    ) {
        self.cacheService = cacheService
        self.accountUseCase = accountUseCase
    }

    public func shouldDisplayWhatsNew(for version: String) async -> Bool {
        guard let email = await email(), let cache, let userCache = cache[email] else {
            return true
        }

        return !userCache.contains(version)
    }

    public func storeWhatsNewDisplayed(for version: String) async {
        guard let email = await email() else { return }

        guard let cache else {
            return save([email: [version]])
        }

        guard let userCache = cache[email] else {
            var newCache = cache
            newCache[email] = [version]
            return save(newCache)
        }

        var newCache = cache
        newCache[email] = userCache + [version]
        save(newCache)
    }

    private func email() async -> String? {
        try? await accountUseCase.fetchAccount().email
    }

    private func save(_ cache: AppVersionPersistanceEntity) {
        try? cacheService.save(cache, for: Self.key)
    }

    private var cache: AppVersionPersistanceEntity? {
        try? cacheService.fetch(for: Self.key)
    }
}
