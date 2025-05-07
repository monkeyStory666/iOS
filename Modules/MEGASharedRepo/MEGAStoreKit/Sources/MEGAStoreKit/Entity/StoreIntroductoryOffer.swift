// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct StoreOffer: Equatable {
    public let type: StoreOfferType
    public let dateRange: Range<Date>

    public init(
        type: StoreOfferType,
        dateRange: Range<Date>
    ) {
        self.type = type
        self.dateRange = dateRange
    }
}

public enum StoreOfferType: Equatable {
    case introductory
    case promotional
}
