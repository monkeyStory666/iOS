// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAStoreKit

public extension StoreOffer {
    static func sample(
        type: StoreOfferType = .introductory,
        dateRange: Range<Date> = .next7days
    ) -> StoreOffer {
        StoreOffer(
            type: type,
            dateRange: dateRange
        )
    }
}

public extension Range where Bound == Date {
    static var next7days: Range<Date> {
        let now = Date()
        return now..<now.addingTimeInterval(7 * 24 * 60 * 60)
    }
}
