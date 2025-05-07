import MEGAInfrastructure
import MEGASdk

public enum DependencyInjection {
    // MARK: - External Injection

    public static var cacheService: any CacheServiceProtocol = UserDefaultsCacheService()
    public static var featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = FeatureFlagsUseCase(
        repo: FeatureFlagsRepository(cacheService: UserDefaultsCacheService())
    )
    public static var sharedSdk: MEGASdk = .init()

    // MARK: - Internal Injection

    public static var storePriceCacheUseCase: some StorePriceCacheUseCaseProtocol {
        StorePriceCacheUseCase(
            storePriceCacheRepository: StorePriceCacheRepository(cacheService: cacheService)
        )
    }

    public static var storeKitRepository: some StoreRepositoryProtocol {
        StoreKitRepository()
    }

    public static var legacyStoreKitRepository: some StoreRepositoryProtocol {
        LegacyStoreKitRepository()
    }

    public static var purchaseRepository: some PurchaseRepositoryProtocol {
        PurchaseRepository(sdk: sharedSdk)
    }
}
