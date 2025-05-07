// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol ChangePasswordUseCaseProtocol {
    func isTwoFactorAuthenticationEnabled() async throws -> Bool
    func changePassword(_ newPassword: String) async throws
    func changePassword(_ newPassword: String, pin: String) async throws
    func testPassword(_ password: String) async -> Bool
}

public struct ChangePasswordUseCase: ChangePasswordUseCaseProtocol {
    private let passwordRepository: any PasswordRepositoryProtocol
    private let passwordTester: any PasswordTesting

    public init(passwordRepository: some PasswordRepositoryProtocol, passwordTester: some PasswordTesting) {
        self.passwordRepository = passwordRepository
        self.passwordTester = passwordTester
    }

    public func isTwoFactorAuthenticationEnabled() async throws -> Bool {
        try await passwordRepository.isTwoFactorAuthenticationEnabled()
    }

    public func changePassword(_ newPassword: String) async throws {
        try await passwordRepository.changePassword(newPassword)
    }

    public func changePassword(_ newPassword: String, pin: String) async throws {
        try await passwordRepository.changePassword(newPassword, pin: pin)
    }

    public func testPassword(_ password: String) async -> Bool {
        await passwordTester.testPassword(password)
    }
}
