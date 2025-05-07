// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGAStoreKit
import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGATest
import MEGAStoreKitMocks
import Testing

final class StoreUseCaseTests {
    private typealias SUT = StoreUseCase

    private let productIdentifier = "ANYIDENTIFIER"
    private var trialIdentifier: String {
        "\(productIdentifier).freeTrial"
    }

    private var mockPurchaseRepo: MockPurchaseRepository!
    private var mockStoreRepo: MockStoreRepository!
    private var mockStorePriceUseCaseCache: MockStorePriceCacheUseCase!
    private var mockRefreshUserDataUseCase: MockRefreshUserDataUseCase!
    private var mockFreeTrialEligibilityUseCase: MockFreeTrialEligibilityUseCase!
    private var sut: SUT!

    init() {
        mockPurchaseRepo = MockPurchaseRepository()
        mockStoreRepo = MockStoreRepository()
        mockStorePriceUseCaseCache = MockStorePriceCacheUseCase()
        mockRefreshUserDataUseCase = MockRefreshUserDataUseCase()
        mockFreeTrialEligibilityUseCase = MockFreeTrialEligibilityUseCase()
        sut = SUT(
            productIdentifier: productIdentifier,
            purchaseRepository: mockPurchaseRepo,
            storeRepository: mockStoreRepo,
            storePriceCacheUseCase: mockStorePriceUseCaseCache,
            refreshUserDataUseCase: mockRefreshUserDataUseCase,
            freeTrialEligibilityUseCase: mockFreeTrialEligibilityUseCase
        )
    }

    deinit {
        mockPurchaseRepo = nil
        mockStoreRepo = nil
        mockStorePriceUseCaseCache = nil
        mockRefreshUserDataUseCase = nil
        sut = nil
    }

    @Test func getProduct_shouldGetFromRepo_withCorrectIdentifier() async throws {
        mockStoreRepo._getProduct = .success(.sample(name: "product1"))

        let result = try await mockStoreRepo.getProduct(with: "product1")

        mockStoreRepo.swt.assertActions(shouldBe: [
            .getProduct(identifier: "product1")
        ])
        #expect(result == .sample(name: "product1"))
    }

    @Test func purchaseProductWithoutFreeTrial_whenPurchaseCompletes_shouldSubmitPurchase() async throws {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = false

        try await sut.purchaseProduct()

        mockStoreRepo.swt.assertActions(shouldBe: [
            .purchaseProduct(identifier: productIdentifier)
        ])
        mockPurchaseRepo.swt.assertActions(shouldBe: [])

        try await mockStoreRepo.triggerPurchaseProductCompletion(with: "receipt-sample")

        mockPurchaseRepo.swt.assertActions(shouldBe: [
            .submitPurchase(receipt: "receipt-sample")
        ])
    }

    @Test func purchaseProductWithFreeTrial_whenPurchaseCompletes_shouldSubmitPurchase() async throws {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = true

        try await sut.purchaseProduct()

        mockStoreRepo.swt.assertActions(shouldBe: [
            .purchaseProduct(identifier: trialIdentifier)
        ])
        mockPurchaseRepo.swt.assertActions(shouldBe: [])

        try await mockStoreRepo.triggerPurchaseProductCompletion(with: "receipt-sample")

        mockPurchaseRepo.swt.assertActions(shouldBe: [
            .submitPurchase(receipt: "receipt-sample")
        ])
    }

    @Test func RestorePurchase_whenRestoreCompletes_shouldSubmitPurchase() async throws {
        mockPurchaseRepo._submitPurchase = .success(())
        mockStoreRepo._restorePurchase = .success(())

        try await sut.restorePurchase()

        mockStoreRepo.swt.assertActions(shouldBe: [.restorePurchase])
        mockPurchaseRepo.swt.assertActions(shouldBe: [])

        try await mockStoreRepo.triggerRestorePurchaseCompletion(
            with: "receipt-sample"
        )

        mockPurchaseRepo.swt.assertActions(shouldBe: [
            .submitPurchase(receipt: "receipt-sample")
        ])
        mockRefreshUserDataUseCase.swt.assert(.notify, isCalled: .once)
    }

    @Test func handleTransactionUpdate_shouldSubmitPurchase_onBackgroundTransactionUpdate() async throws {
        mockPurchaseRepo._submitPurchase = .success(())

        sut.handleTransactionUpdates()

        mockStoreRepo.swt.assertActions(shouldBe: [.onBackgroundTransactionUpdate])
        mockPurchaseRepo.swt.assertActions(shouldBe: [])

        try await mockStoreRepo.triggerTransactionUpdateHandler(with: "receipt-sample")

        mockStoreRepo.swt.assertActions(shouldBe: [
            .onBackgroundTransactionUpdate
        ])
        mockPurchaseRepo.swt.assertActions(shouldBe: [
            .submitPurchase(receipt: "receipt-sample")
        ])
    }

    @Test func priceChangeNotCalled_whenIneligibleForFreeTrial_whenFailedToGetProduct() async {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = false

        mockStoreRepo._getProduct = .failure(ErrorInTest())

        await confirmation(expectedCount: 0) { confirmation in
            let (task, _) = sut.getLocalizedPriceTask { _ in
                confirmation.confirm()
            }

            await task.value
        }

        mockStoreRepo.swt.assert(.getProduct(identifier: productIdentifier), isCalled: .once)
    }

    @Test func priceChangeCalled_whenEligibleForFreeTrial_whenSuccessfullyGetProductAndPriceIsDifferent() async {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = true

        mockStorePriceUseCaseCache.prices = [:]
        mockStoreRepo._getProduct = .success(.sample(name: "product1"))

        await confirmation { confirmation in
            let (task, _) = sut.getLocalizedPriceTask { _ in
                confirmation.confirm()
            }

            await task.value
        }

        mockStoreRepo.swt.assert(.getProduct(identifier: trialIdentifier), isCalled: .once)
    }

    @Test func purchaseProduct_whenSubmitPurchaseError_shouldThrowErrorOnCompletion() async throws {
        mockPurchaseRepo._submitPurchase = .failure(ErrorInTest())

        try await sut.purchaseProduct()

        do {
            try await mockStoreRepo.triggerPurchaseProductCompletion(
                with: "receipt-sample"
            )
            Issue.record("Should have thrown an error")
        } catch {}

        mockRefreshUserDataUseCase.swt.assert(.notify, isCalled: 0.times)
    }

    @Test func purchaseProduct_whenAlreadyExistError_shouldNotThrowError() async throws {
        mockStoreRepo._purchaseProduct = .failure(PurchaseError.alreadyExist)

        try await sut.purchaseProduct()

        try await mockStoreRepo.triggerPurchaseProductCompletion(
            with: "receipt-sample"
        )
    }

    @Test func purchaseProduct_whenErrorAlreadyExist_shouldThrowError_andNotifyRefreshUserData() async throws {
        mockPurchaseRepo._submitPurchase = .failure(PurchaseError.alreadyExist)

        try await sut.purchaseProduct()

        do {
            try await mockStoreRepo.triggerPurchaseProductCompletion(
                with: "receipt-sample"
            )
            Issue.record("Should have thrown an error")
        } catch {}

        mockRefreshUserDataUseCase.swt.assert(.notify, isCalled: .once)
    }

    @Test func purchaseProduct_whenSubmitPurchaseSuccess_shouldReturnTrueWhenCompletingTransaction() async throws {
        mockPurchaseRepo._submitPurchase = .success(())

        try await sut.purchaseProduct()

        try await mockStoreRepo.triggerPurchaseProductCompletion(
            with: "receipt-sample"
        )

        mockRefreshUserDataUseCase.swt.assert(.notify, isCalled: .once)
    }

    @Test func eligibleIntroductoryOffer_whenIneligibleForFreeTrial_shouldGetProductWithNormalIdentifier() async {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = false

        _ = await sut.eligibleIntroductoryOffer()

        mockStoreRepo.swt.assert(.getProduct(identifier: productIdentifier), isCalled: .once)
    }

    @Test func eligibleIntroductoryOffer_whenEligibleForFreeTrial_shouldGetProductWithFreeTrialIdentifier() async {
        mockFreeTrialEligibilityUseCase._isEligibleForFreeTrial = true

        _ = await sut.eligibleIntroductoryOffer()

        mockStoreRepo.swt.assert(.getProduct(identifier: trialIdentifier), isCalled: .once)
    }

    @Test func eligibleIntroductoryOffer_shouldGetFromRepository() async throws {
        func assert(
            offers: [StoreOffer],
            shouldReturnIntroOffer expectedOffer: StoreOffer?,
            line: UInt = #line
        ) async {
            mockStoreRepo._getProduct = .success(.sample(
                name: "product1",
                offers: offers
            ))

            let result = await sut.eligibleIntroductoryOffer()

            #expect(result == expectedOffer)
        }

        let introductoryOffer = StoreOffer.sample(type: .introductory)

        await assert(offers: [], shouldReturnIntroOffer: nil)
        await assert(offers: [.sample(type: .promotional)], shouldReturnIntroOffer: nil)
        await assert(
            offers: [
                .sample(type: .promotional),
                .sample(type: .promotional)
            ],
            shouldReturnIntroOffer: nil
        )
        await assert(offers: [introductoryOffer], shouldReturnIntroOffer: introductoryOffer)
        await assert(
            offers: [
                .sample(type: .promotional),
                introductoryOffer
            ],
            shouldReturnIntroOffer: introductoryOffer
        )
    }

    @Test func handleTransactionUpdate_whenSubmitPurchaseError_returnFalse() async throws {
        mockPurchaseRepo._submitPurchase = .failure(ErrorInTest())

        sut.handleTransactionUpdates()

        do {
            try await mockStoreRepo.triggerTransactionUpdateHandler(with: "receipt-sample")
            Issue.record("Should have thrown an error")
        } catch {}
    }

    @Test func handleTransactionUpdate_whenSubmitPurchaseSuccess_returnTrue() async throws {
        mockPurchaseRepo._submitPurchase = .success(())

        sut.handleTransactionUpdates()

        try await mockStoreRepo.triggerTransactionUpdateHandler(with: "receipt-sample")
    }
}
