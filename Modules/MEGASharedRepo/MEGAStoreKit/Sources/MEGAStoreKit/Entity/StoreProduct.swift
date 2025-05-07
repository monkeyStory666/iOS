// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct StoreProduct {
    public struct Price {
        public let decimalPrice: Decimal
        public let displayPrice: String
        public let currencyCode: String?
        public let displayPriceFormatter: (Decimal) -> String
        public let priceFormatter: (String) -> Decimal?

        public init(
            decimalPrice: Decimal,
            displayPrice: String,
            currencyCode: String?,
            displayPriceFormatter: @escaping (Decimal) -> String,
            priceFormatter: @escaping (String) -> Decimal?
        ) {
            self.decimalPrice = decimalPrice
            self.displayPrice = displayPrice
            self.currencyCode = currencyCode
            self.displayPriceFormatter = displayPriceFormatter
            self.priceFormatter = priceFormatter
        }
    }

    public let name: String
    public let identifier: String
    public let price: Price
    public let offers: [StoreOffer]
    public let isEligibleForIntroOffer: () async -> Bool

    public init(
        name: String,
        identifier: String,
        price: Price,
        offers: [StoreOffer],
        isEligibleForIntroOffer: @escaping () async -> Bool
    ) {
        self.name = name
        self.identifier = identifier
        self.price = price
        self.offers = offers
        self.isEligibleForIntroOffer = isEligibleForIntroOffer
    }
}

extension StoreProduct {
    var introductoryOffer: StoreOffer? {
        offers.first { $0.type == .introductory }
    }

    var localizedPrice: String {
        price.displayPrice
    }
}

extension StoreProduct: Equatable {
    public static func == (lhs: StoreProduct, rhs: StoreProduct) -> Bool {
        lhs.name == rhs.name
            && lhs.identifier == rhs.identifier
            && lhs.localizedPrice == rhs.localizedPrice
    }
}
