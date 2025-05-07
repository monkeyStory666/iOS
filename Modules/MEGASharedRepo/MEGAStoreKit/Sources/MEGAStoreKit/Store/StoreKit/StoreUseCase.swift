// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGASwift

public protocol StoreUseCaseProtocol {
    func purchaseProduct() async throws
    func getLocalizedPriceTask(
        _ onPriceChange: @Sendable @escaping (String?) -> Void
    ) -> (task: Task<Void, Never>, cachedValue: String?)
    func restorePurchase() async throws
    func eligibleIntroductoryOffer() async -> StoreOffer?
    func handleTransactionUpdates()
    func getProduct() async -> StoreProduct?
}

public extension StoreUseCaseProtocol {
    func getLocalizedPrice(
        _ onPriceChange: @Sendable @escaping (String?) -> Void
    ) -> String? {
        let (_, value) = getLocalizedPriceTask(onPriceChange)
        return value
    }
}

public struct StoreUseCase: StoreUseCaseProtocol, @unchecked Sendable {
    private let productIdentifier: String
    private let purchaseRepository: any PurchaseRepositoryProtocol
    private let storeRepository: any StoreRepositoryProtocol
    private let storePriceCacheUseCase: any StorePriceCacheUseCaseProtocol
    private let refreshUserDataUseCase: any RefreshUserDataNotificationUseCaseProtocol
    private let freeTrialEligibilityUseCase: any FreeTrialEligibilityUseCaseProtocol

    public init(
        productIdentifier: String,
        purchaseRepository: some PurchaseRepositoryProtocol,
        storeRepository: some StoreRepositoryProtocol,
        storePriceCacheUseCase: some StorePriceCacheUseCaseProtocol,
        refreshUserDataUseCase: some RefreshUserDataNotificationUseCaseProtocol,
        freeTrialEligibilityUseCase: some FreeTrialEligibilityUseCaseProtocol
    ) {
        self.productIdentifier = productIdentifier
        self.purchaseRepository = purchaseRepository
        self.storeRepository = storeRepository
        self.storePriceCacheUseCase = storePriceCacheUseCase
        self.refreshUserDataUseCase = refreshUserDataUseCase
        self.freeTrialEligibilityUseCase = freeTrialEligibilityUseCase
    }

    public func getLocalizedPriceTask(
        _ onPriceChange: @Sendable @escaping (String?) -> Void
    ) -> (task: Task<Void, Never>, cachedValue: String?) {
        let cachedNonFreeTrialPrice = storePriceCacheUseCase.getPrice(for: productIdentifier)

        let task = Task {
            guard let fetchedProduct = await getProduct() else { return }

            onPriceChange(fetchedProduct.localizedPrice)
        }

        return (task, cachedNonFreeTrialPrice)
    }

    public func purchaseProduct() async throws {
        try await runActionIgnoringAlreadyExistError {
            try await storeRepository.purchaseProduct(
                with: await productIdToUse()
            ) { receipt in
                try await submitPurchase(with: receipt)
            }
        }
    }

    public func restorePurchase() async throws {
        try await runActionIgnoringAlreadyExistError {
            try await storeRepository.restorePurchase() { receipt in
                try await submitPurchase(with: receipt)
            }
        }
    }

    public func eligibleIntroductoryOffer() async -> StoreOffer? {
        guard
            let product = await getProduct(),
            let introductoryOffer = product.introductoryOffer
        else {
            return nil
        }

        return await product.isEligibleForIntroOffer() ? introductoryOffer : nil
    }

    public func handleTransactionUpdates() {
        storeRepository.onBackgroundTransactionUpdate { receipt in
            try await submitPurchase(with: receipt)
        }
    }

    public func getProduct() async -> StoreProduct? {
        guard let product = try? await storeRepository.getProduct(with: await productIdToUse()) else { return nil }

        if product.localizedPrice != storePriceCacheUseCase.getPrice(for: product.identifier) {
            storePriceCacheUseCase.save(price: product.localizedPrice, for: product.identifier)
        }

        return product
    }

    private func submitPurchase(with receipt: String) async throws {
        do {
            try await purchaseRepository.submitPurchase(with: receipt)
            refreshUserDataUseCase.notify()
        } catch {
            if isError(error, equalTo: PurchaseError.alreadyExist) {
                refreshUserDataUseCase.notify()
            }

            throw error
        }
    }

    /// This function is used to ignore the `Already Exist` purchase errors
    /// because that indicates that the purchase is already active in the user account
    /// and that we only need to refresh user data
    private func runActionIgnoringAlreadyExistError(
        _ action: () async throws -> Void
    ) async throws {
        do {
            try await action()
        } catch {
            if !isError(error, equalTo: PurchaseError.alreadyExist) {
                throw error
            }
        }
    }

    private func productIdToUse() async -> String {
        await freeTrialEligibilityUseCase.isEligibleForFreeTrial(productIdentifier)
            ? "\(productIdentifier).freeTrial"
            : productIdentifier
    }
}
