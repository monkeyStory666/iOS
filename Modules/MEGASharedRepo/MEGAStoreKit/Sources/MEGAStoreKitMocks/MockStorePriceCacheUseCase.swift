// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAStoreKit
import MEGATest

public final class MockStorePriceCacheUseCase: MockObject<MockStorePriceCacheUseCase.Action>, StorePriceCacheUseCaseProtocol {
    public enum Action: Equatable {
        case save(price: String, id: String)
        case getPrice(id: String)
        case getPrices
    }

    public var prices: [String: String]

    public init(prices: [String: String] = [:]) {
        self.prices = prices
    }

    public func save(price: String, for identifier: String) {
        actions.append(.save(price: price, id: identifier))
        self.prices[identifier] = price
    }

    public func getPrice(for identifier: String) -> String? {
        actions.append(.getPrice(id: identifier))
        return prices[identifier]
    }

    public func getPrices() -> [String: String] {
        actions.append(.getPrices)
        return prices
    }
}
