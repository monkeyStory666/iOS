// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol PasswordRepositoryProtocol {
    func isTwoFactorAuthenticationEnabled() async throws -> Bool
    func changePassword(_ newPassword: String) async throws
    func changePassword(_ newPassword: String, pin: String) async throws
}
