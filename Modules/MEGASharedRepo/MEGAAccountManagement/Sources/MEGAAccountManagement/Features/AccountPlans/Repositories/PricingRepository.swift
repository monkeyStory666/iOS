// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public protocol PricingRepositoryProtocol {
    func getPricing() async throws -> PricingEntity
}

public struct PricingRepository: PricingRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func getPricing() async throws -> PricingEntity {
        try await withAsyncThrowingValue { completion in
            sdk.getPricingWith(RequestDelegate { result in
                switch result {
                case .success(let request):
                    completion(.success(request.pricingEntity))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}

extension MEGARequest {
    var pricingEntity: PricingEntity {
        PricingEntity(products: pricingProducts)
    }

    var pricingProducts: [PricingProductEntity] {
        guard let pricing, pricing.products > 0 else { return [] }

        var products: [PricingProductEntity] = []
        for index in 0..<pricing.products {
            products.append(.init(
                storeKitIdentifier: pricing.iOSID(atProductIndex: index),
                durationInMonths: Int(pricing.months(atProductIndex: index)),
                description: pricing.description(atProductIndex: index),
                trialDurationInDays: Int(pricing.trialDurationInDays(atProductIndex: index))
            ))
        }

        return products
    }
}
