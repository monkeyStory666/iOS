// Copyright © 2025 MEGA Limited. All rights reserved.

public protocol MultipleProductStoreUseCaseProtocol {
    func productIdentifiers() async -> [ProductIdentifier]
    func getProduct(with identifier: ProductIdentifier) async -> StoreProduct?
    func purchaseProduct(with identifier: ProductIdentifier) async throws
    func restorePurchases() async throws
    func eligibleIntroductoryOffers() async -> [ProductIdentifier: StoreOffer]
    func handleTransactionUpdates()
}

public struct MultipleProductStoreUseCase: MultipleProductStoreUseCaseProtocol, @unchecked Sendable {
    private let fetchProductIdentifiersUseCase: any FetchProductIdentifierUseCaseProtocol
    private let storeUseCaseFactory: (ProductIdentifier?) -> any StoreUseCaseProtocol

    public init(
        fetchProductIdentifiersUseCase: some FetchProductIdentifierUseCaseProtocol,
        storeUseCaseFactory: @escaping (ProductIdentifier?) -> some StoreUseCaseProtocol
    ) {
        self.fetchProductIdentifiersUseCase = fetchProductIdentifiersUseCase
        self.storeUseCaseFactory = storeUseCaseFactory
    }

    public func productIdentifiers() async -> [ProductIdentifier] {
        (try? await fetchProductIdentifiersUseCase.productIdentifiers()) ?? []
    }

    public func getProduct(with identifier: ProductIdentifier) async -> StoreProduct? {
        await storeUseCaseFactory(identifier).getProduct()
    }

    public func purchaseProduct(with identifier: ProductIdentifier) async throws {
        let storeUseCase = storeUseCaseFactory(identifier)
        try await storeUseCase.purchaseProduct()
    }

    public func restorePurchases() async throws {
        // This method doesn't care about product identifiers
        try await storeUseCaseFactory(nil).restorePurchase()
    }

    public func eligibleIntroductoryOffers() async -> [ProductIdentifier: StoreOffer] {
        var offers = [ProductIdentifier: StoreOffer]()

        for product in await productIdentifiers() {
            let storeUseCase = storeUseCaseFactory(product)
            offers[product] = await storeUseCase.eligibleIntroductoryOffer()
        }

        return offers
    }

    public func handleTransactionUpdates() {
        // This method doesn't care about product identifiers
        storeUseCaseFactory(nil).handleTransactionUpdates()
    }
}
