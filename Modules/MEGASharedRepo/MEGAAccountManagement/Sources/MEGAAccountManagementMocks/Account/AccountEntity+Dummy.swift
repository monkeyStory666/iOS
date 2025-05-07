// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement

public extension AccountEntity {
    static var dummy: AccountEntity { .sample() }

    static func sample(
        handle: HandleEntity = .invalid,
        base64Handle: String = "dummy",
        firstName: String = "Dummy",
        lastName: String = "Name",
        email: String = "dummy.email@mega.co.nz"
    ) -> AccountEntity {
        AccountEntity(
            handle: handle,
            base64Handle: base64Handle,
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }
}
