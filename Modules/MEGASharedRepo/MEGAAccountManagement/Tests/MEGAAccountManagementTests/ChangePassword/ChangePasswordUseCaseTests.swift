// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAccountManagementMocks
import Testing

struct ChangePasswordUseCaseTests {
    @Test func testIsTwoFactorAuthenticationEnabled_shouldGetFromRepository() async throws {
        func assert(
            isTwoFAEnabled: Bool,
            line: UInt = #line
        ) async throws {
            let repository = MockPasswordRepository(
                isTwoFactorAuthenticationEnabled: isTwoFAEnabled
            )
            let sut = makeSUT(passwordRepository: repository)

            let result = try await sut.isTwoFactorAuthenticationEnabled()

            repository.swt.assertActions(
                shouldBe: [.isTwoFactorAuthenticationEnabled]
            )
            #expect(result == isTwoFAEnabled)
        }

        try await assert(isTwoFAEnabled: true)
        try await assert(isTwoFAEnabled: false)
    }

    @Test func testChangePassword_shouldCallRepository() async throws {
        let repository = MockPasswordRepository()
        let sut = makeSUT(passwordRepository: repository)

        let newPassword = String.random(withPrefix: "newPass")

        try await sut.changePassword(newPassword)

        repository.swt.assertActions(
            shouldBe: [.changePassword(newPassword: newPassword)]
        )
    }

    @Test func testChangePasswordWithPin_shouldCallRepository() async throws {
        let repository = MockPasswordRepository()
        let sut = makeSUT(passwordRepository: repository)

        let newPassword = String.random(withPrefix: "newPass")
        let pin = String.random(withPrefix: "pin")

        try await sut.changePassword(newPassword, pin: pin)

        repository.swt.assertActions(
            shouldBe: [.changePasswordWithPin(
                newPassword: newPassword,
                pin: pin
            )]
        )
    }

    @Test func testTestPassword_shouldTestInRepository() async {
        func assert(
            testPasswordResult: Bool,
            line: UInt = #line
        ) async {
            let tester = MockPasswordTesting(testPassword: testPasswordResult)
            let sut = makeSUT(passwordTester: tester)
            let password = String.random(withPrefix: "password")

            let result = await sut.testPassword(password)

            tester.swt.assertActions(shouldBe: [.testPassword(password: password)])
            #expect(result == testPasswordResult)
        }

        await assert(testPasswordResult: true)
        await assert(testPasswordResult: false)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        passwordRepository: PasswordRepositoryProtocol = MockPasswordRepository(),
        passwordTester: PasswordTesting = MockPasswordTesting()
    ) -> ChangePasswordUseCase {
        ChangePasswordUseCase(
            passwordRepository: passwordRepository,
            passwordTester: passwordTester
        )
    }
}
