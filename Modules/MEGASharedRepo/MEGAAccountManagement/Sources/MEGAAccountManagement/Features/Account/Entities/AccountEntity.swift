// Copyright © 2023 MEGA Limited. All rights reserved.

public struct AccountEntity: Codable, Equatable {
    public let handle: HandleEntity
    public let base64Handle: Base64HandleEntity
    public let firstName: String
    public let lastName: String
    public let email: String

    public var fullName: String {
        "\(firstName) \(lastName)"
    }

    public init(
        handle: HandleEntity,
        base64Handle: Base64HandleEntity,
        firstName: String,
        lastName: String,
        email: String
    ) {
        self.handle = handle
        self.base64Handle = base64Handle
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
