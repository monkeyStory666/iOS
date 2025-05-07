// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAStoreKit
import MEGATest

public final class MockFetchProductIdentifierUseCase:
    MockObject<MockFetchProductIdentifierUseCase.Action>,
    FetchProductIdentifierUseCaseProtocol {

    public enum Action: Equatable {
        case productIdentifiers
    }

    public var _productIdentifiers: Result<[ProductIdentifier], Error>

    public init(
        productIdentifiers: Result<[ProductIdentifier], Error> = .success([])
    ) {
        _productIdentifiers = productIdentifiers
    }

    public func productIdentifiers() async throws -> [ProductIdentifier] {
        actions.append(.productIdentifiers)
        return try _productIdentifiers.get()
    }
}
