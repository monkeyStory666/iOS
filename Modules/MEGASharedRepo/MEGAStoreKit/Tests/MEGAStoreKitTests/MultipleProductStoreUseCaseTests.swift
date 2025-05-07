// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAStoreKit
import MEGAStoreKitMocks
import MEGATest
import Testing

struct MultipleProductStoreUseCaseTests {
    @Test func productIdentifiers_whenSuccessful() async throws {
        let expectedIdentifiers: [ProductIdentifier] = [.sample(), .sample()]
        let mockFetchProductIdentifiersUseCase = MockFetchProductIdentifierUseCase(
            productIdentifiers: .success(expectedIdentifiers)
        )
        let sut = makeSUT(fetchProductIdentifiersUseCase: mockFetchProductIdentifiersUseCase)

        #expect(await sut.productIdentifiers() == expectedIdentifiers)
    }

    @Test func productIdentifiers_whenFailed() async throws {
        let mockFetchProductIdentifiersUseCase = MockFetchProductIdentifierUseCase(
            productIdentifiers: .failure(ErrorInTest())
        )
        let sut = makeSUT(fetchProductIdentifiersUseCase: mockFetchProductIdentifiersUseCase)

        #expect(await sut.productIdentifiers() == [])
    }

    @Test func getProduct() async throws {
        let expectedProduct = StoreProduct.sample()
        var storeUseCaseIdentifier: ProductIdentifier?
        let mockStoreUseCase = MockStoreUseCase(getProduct: expectedProduct)
        let sut = makeSUT(storeUseCaseFactory: {
            storeUseCaseIdentifier = $0
            return mockStoreUseCase
        })

        let productIdentifier = ProductIdentifier.sample()
        let product = await sut.getProduct(with: productIdentifier)

        #expect(product == expectedProduct)
        #expect(storeUseCaseIdentifier == productIdentifier)
    }

    @Test func purchaseProduct() async throws {
        var storeUseCaseIdentifier: ProductIdentifier?
        let mockStoreUseCase = MockStoreUseCase(purchaseProduct: .success(()))
        let sut = makeSUT(storeUseCaseFactory: {
            storeUseCaseIdentifier = $0
            return mockStoreUseCase
        })

        let productIdentifier = ProductIdentifier.sample()
        try await sut.purchaseProduct(with: productIdentifier)

        mockStoreUseCase.swt.assertActions(shouldBe: [.purchaseProduct])
        #expect(storeUseCaseIdentifier == productIdentifier)
    }

    @Test func restorePurchases() async throws {
        let mockStoreUseCase = MockStoreUseCase(restorePurchase: .success(()))
        let sut = makeSUT(storeUseCaseFactory: { _ in mockStoreUseCase })

        try await sut.restorePurchases()

        mockStoreUseCase.swt.assertActions(shouldBe: [.restorePurchase])
    }

    @Test func eligibleIntroductoryOffers() async throws {
        let expectedProductIdentifier = ProductIdentifier.sample()
        let expectedOffer = StoreOffer.sample()
        let mockFetchProductIdentifiersUseCase = MockFetchProductIdentifierUseCase(
            productIdentifiers: .success([expectedProductIdentifier])
        )
        let mockStoreUseCase = MockStoreUseCase(eligibleIntroductoryOffer: expectedOffer)
        let sut = makeSUT(
            fetchProductIdentifiersUseCase: mockFetchProductIdentifiersUseCase,
            storeUseCaseFactory: { _ in mockStoreUseCase }
        )

        let offers = await sut.eligibleIntroductoryOffers()

        #expect(offers.count == 1)
        #expect(offers[expectedProductIdentifier] == expectedOffer)
    }

    @Test func handleTransactionUpdates() async throws {
        let mockStoreUseCase = MockStoreUseCase()
        let sut = makeSUT(storeUseCaseFactory: { _ in mockStoreUseCase })

        sut.handleTransactionUpdates()

        mockStoreUseCase.swt.assertActions(shouldBe: [.handleTransactionUpdates])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        fetchProductIdentifiersUseCase: some FetchProductIdentifierUseCaseProtocol = MockFetchProductIdentifierUseCase(),
        storeUseCaseFactory: @escaping (ProductIdentifier?) -> some StoreUseCaseProtocol = { _ in MockStoreUseCase() }
    ) -> MultipleProductStoreUseCase {
        MultipleProductStoreUseCase(
            fetchProductIdentifiersUseCase: fetchProductIdentifiersUseCase,
            storeUseCaseFactory: storeUseCaseFactory
        )
    }
}
