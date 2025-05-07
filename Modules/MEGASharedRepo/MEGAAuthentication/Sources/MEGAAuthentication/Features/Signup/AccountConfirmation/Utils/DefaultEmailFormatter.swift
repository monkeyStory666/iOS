// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure

public struct DefaultEmailFormatter: EmailFormatUseCaseProtocol {
    public func createEmailFormat() async -> EmailEntity {
        EmailEntity(recipients: [Constants.Email.support], subject: "", body: "")
    }
}
