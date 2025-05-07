// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAuthentication
import MEGATest

public final class MockChangePasswordUseCase:
    MockObject<MockChangePasswordUseCase.Action>,
    ChangePasswordUseCaseProtocol {
    public enum Action: Equatable {
        case isTwoFactorAuthenticationEnabled
        case changePassword(String)
        case changePasswordTwoFA(_ newPassword: String, _ pin: String)
        case testPassword(String)
    }

    private var changePassword: Result<Void, Error>
    private var isTwoFAEnabled: Result<Bool, TwoFactorAuthenticationErrorEntity>
    private var isTestPasswordSuccessful: Bool

    public init(
        changePassword: Result<Void, Error> = .success(()),
        isTwoFAEnabled: Result<Bool, TwoFactorAuthenticationErrorEntity> = .success(false),
        isTestPasswordSuccessful: Bool = false
    ) {
        self.changePassword = changePassword
        self.isTwoFAEnabled = isTwoFAEnabled
        self.isTestPasswordSuccessful = isTestPasswordSuccessful

        super.init()
    }

    public func isTwoFactorAuthenticationEnabled() async throws -> Bool {
        actions.append(.isTwoFactorAuthenticationEnabled)
        return try isTwoFAEnabled.get()
    }

    public func changePassword(_ newPassword: String) async throws {
        actions.append(.changePassword(newPassword))
        try changePassword.get()
    }

    public func changePassword(_ newPassword: String, pin: String) async throws {
        actions.append(.changePasswordTwoFA(newPassword, pin))
        try changePassword.get()
    }

    public func testPassword(_ password: String) async -> Bool {
        actions.append(.testPassword(password))
        return isTestPasswordSuccessful
    }
}
