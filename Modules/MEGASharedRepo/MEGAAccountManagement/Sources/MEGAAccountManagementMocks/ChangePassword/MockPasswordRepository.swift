// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockPasswordRepository:
    MockObject<MockPasswordRepository.Action>,
    PasswordRepositoryProtocol {
    public enum Action: Equatable {
        case isTwoFactorAuthenticationEnabled
        case changePassword(newPassword: String)
        case changePasswordWithPin(newPassword: String, pin: String)
    }

    public var _isTwoFactorAuthenticationEnabled: Bool

    public init(
        isTwoFactorAuthenticationEnabled: Bool = true
    ) {
        self._isTwoFactorAuthenticationEnabled = isTwoFactorAuthenticationEnabled
    }

    public func isTwoFactorAuthenticationEnabled() async throws -> Bool {
        actions.append(.isTwoFactorAuthenticationEnabled)
        return _isTwoFactorAuthenticationEnabled
    }

    public func changePassword(_ newPassword: String) async throws {
        actions.append(.changePassword(newPassword: newPassword))
    }

    public func changePassword(
        _ newPassword: String,
        pin: String
    ) async throws {
        actions.append(.changePasswordWithPin(newPassword: newPassword, pin: pin))
    }
}
