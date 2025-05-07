// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import StoreKit

extension Product {
    var offers: [StoreOffer] {
        guard subscription != nil else { return [] }

        var offers: [StoreOffer] = []
        if let introductoryOffer { offers.append(introductoryOffer) }
        offers.append(contentsOf: promotionalOffers)
        return offers
    }

    var introductoryOffer: StoreOffer? {
        guard let introductoryOffer = subscription?.introductoryOffer else {
            return nil
        }

        return StoreOffer(
            type: .introductory,
            dateRange: introductoryOffer.period.dateRange()
        )
    }

    var promotionalOffers: [StoreOffer] {
        subscription?.promotionalOffers.map { offer in
            StoreOffer(
                type: .promotional,
                dateRange: offer.period.dateRange()
            )
        } ?? []
    }
}

extension SKProduct {
    var offers: [StoreOffer] {
        self.discounts.map { discount in
            StoreOffer(
                type: {
                    switch discount.type {
                    case .introductory:
                        return .introductory
                    case .subscription:
                        return .promotional
                    @unknown default:
                        return .promotional
                    }
                }(),
                dateRange: {
                    .init(
                        adding: discount.subscriptionPeriod.dateComponents(),
                        from: .now,
                        calendar: .current
                    )
                }()
            )
        }
    }
}
