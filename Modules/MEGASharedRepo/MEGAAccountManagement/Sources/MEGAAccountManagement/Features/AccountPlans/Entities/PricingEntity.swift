// Copyright © 2024 MEGA Limited. All rights reserved.

public struct PricingEntity: Equatable {
    public let products: [PricingProductEntity]

    public init(products: [PricingProductEntity]) {
        self.products = products
    }
}
