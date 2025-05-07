// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct NewAccountInformationEntity: Equatable {
    var name: String
    var email: String
    var password: String

    public init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}
