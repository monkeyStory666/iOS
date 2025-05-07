// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

public protocol NotificationRegistrationRepositoryProtocol {
    func register(deviceToken: String)
}

public final class NotificationRegistrationRepository: NotificationRegistrationRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    /// Do nothing right now, because right now push notifications is only supported
    /// for apps that has `ENABLE_CHAT` defined, while VPN and PWM  does not
    /// enable chat.
    public func register(deviceToken: String) {
//         sdk.registeriOSdeviceToken(deviceToken)
    }
}
