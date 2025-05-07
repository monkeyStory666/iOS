// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

extension AccountSuspensionType {
    init?(from event: MEGAEvent) {
        guard event.type == .accountBlocked else { return nil }
        guard let accountSuspensionType = AccountSuspensionType(rawValue: event.number) else { return nil }

        self = accountSuspensionType
    }
}
