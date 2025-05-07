// Copyright © 2025 MEGA Limited. All rights reserved.

public struct ProductIdentifier: Hashable, Sendable {
    public let identifier: String
    public let durationInMonths: Int
    public let type: ProductIdentifierType

    public init(
        identifier: String,
        durationInMonths: Int,
        type: ProductIdentifierType
    ) {
        self.identifier = identifier
        self.durationInMonths = durationInMonths
        self.type = type
    }
}
