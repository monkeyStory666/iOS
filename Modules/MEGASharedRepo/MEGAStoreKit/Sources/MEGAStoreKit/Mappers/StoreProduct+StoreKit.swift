// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import StoreKit

extension StoreProduct {
    init(storeKitProduct: Product) {
        self.init(
            name: storeKitProduct.displayName,
            identifier: storeKitProduct.id,
            price: .init(
                decimalPrice: storeKitProduct.price,
                displayPrice: storeKitProduct.displayPrice,
                currencyCode: storeKitProduct.priceFormatStyle.currencyCode,
                displayPriceFormatter: { $0.formatted(storeKitProduct.priceFormatStyle) },
                priceFormatter: { try? Decimal($0, format: storeKitProduct.priceFormatStyle) }
            ),
            offers: storeKitProduct.offers,
            isEligibleForIntroOffer: {
                guard
                    let subscription = storeKitProduct.subscription,
                    let offer = storeKitProduct.introductoryOffer,
                    offer.dateRange.contains(.now)
                else { return false }

                guard !shouldOverrideFreeTrialEligibility() else { return true }

                return await subscription.isEligibleForIntroOffer
            }
        )
    }

    init(skProduct: SKProduct) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = skProduct.priceLocale

        self.init(
            name: skProduct.localizedTitle,
            identifier: skProduct.productIdentifier,
            price: .init(
                decimalPrice: skProduct.price.decimalValue,
                displayPrice: skProduct.displayPrice,
                currencyCode: {
                    if #available(iOS 16.0, *) {
                        skProduct.priceLocale.currency?.identifier
                    } else {
                        skProduct.priceLocale.currencyCode
                    }
                }(),
                displayPriceFormatter: {
                    numberFormatter.string(
                        from: NSDecimalNumber(decimal: $0) as NSNumber
                    ) ?? ""
                },
                priceFormatter: {
                    numberFormatter.number(from: $0)?.decimalValue
                }
            ),
            offers: skProduct.offers,
            isEligibleForIntroOffer: {
                skProduct.isEligibleForIntroductoryOffer
            }
        )
    }
}

/// This function is needed for to help QAs retest this flow in test environments,
/// since `isEligibleForIntroOffer` always returns false even after we
/// used the `Reset Eligibility` button in the app store's sandbox manage
/// subscription page.
///
/// It checks for the value of `Override Free Trial Eligibility` toggle
/// in QA settings
private func shouldOverrideFreeTrialEligibility() -> Bool {
    DependencyInjection.featureFlagsUseCase.get(for: .overrideFreeTrialEligibility) == true
}

extension SKProduct {
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }

    /// Do not use. Always returns `false`, because currently there's no way to check
    /// if user is eligible for introductory offer in StoreKit 1.
    ///
    /// Since we only use StoreKit 2 for checking eligibility, we can safely return `false` in StoreKit 1.
    var isEligibleForIntroductoryOffer: Bool {
        false
    }
}
