// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import MEGAStoreKit

public extension StoreProduct {
    static func sample(
        name: String = "productName",
        identifier: String = "productIdentifier",
        price: StoreProduct.Price = .sample(),
        offers: [StoreOffer] = [],
        isEligibleForIntroOffer: @escaping () async -> Bool = { true }
    ) -> Self {
        StoreProduct(
            name: name,
            identifier: identifier,
            price: price,
            offers: offers,
            isEligibleForIntroOffer: isEligibleForIntroOffer
        )
    }
}

public extension StoreProduct.Price {
    static func sample(
        decimalPrice: Decimal = 0.0,
        displayPrice: String = "$0.00",
        currencyCode: String? = "USD",
        displayPriceFormatter: @escaping (Decimal) -> String = { "\($0)" },
        priceFormatter: @escaping (String) -> Decimal? = { Decimal(string: $0) }
    ) -> Self {
        StoreProduct.Price(
            decimalPrice: decimalPrice,
            displayPrice: displayPrice,
            currencyCode: currencyCode,
            displayPriceFormatter: displayPriceFormatter,
            priceFormatter: priceFormatter
        )
    }
}

public extension ProductIdentifier {
    static func sample(
        identifier: String = "com.mega.vpn.monthly",
        durationInMonths: Int = 1,
        type: ProductIdentifierType = .autoRenewable
    ) -> Self {
        .init(
            identifier: identifier,
            durationInMonths: durationInMonths,
            type: type
        )
    }
}
