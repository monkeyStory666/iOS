// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public extension EmailEntity {
    static func dummy(
        recipients: [String] = ["any-email@mega.nz"],
        subject: String = .random(),
        body: String = .random()
    ) -> Self {
        EmailEntity(
            recipients: recipients,
            subject: subject,
            body: body
        )
    }
}
