// Copyright © 2025 MEGA Limited. All rights reserved.

public struct HardcodedProductIdentifierUseCase: FetchProductIdentifierUseCaseProtocol {
    private let identifiers: [ProductIdentifier]

    public init(identifiers: [ProductIdentifier]) {
        self.identifiers = identifiers
    }

    public func productIdentifiers() -> [ProductIdentifier] {
        identifiers
    }
}
