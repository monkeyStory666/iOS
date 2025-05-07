// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct PasswordRepositoryTests {
    @Test func testIsTwoFactorAuthEnabled_whenMyEmailNil_shouldReturnFalse() async throws {
        let sut = makeSUT(sdk: MockPasswordRepositorySdk(_myEmail: nil))

        let result = try await sut.isTwoFactorAuthenticationEnabled()

        #expect(result == false)
    }

    @Test func testIsTwoFactorAuthEnabled_whenSucceeded_shouldReturnRequestFlag() async throws {
        func assert(
            whenSdkFlag sdkFlag: Bool,
            isTwoFAEnabled: Bool,
            line: UInt = #line
        ) async throws {
            let expectedEmail = "anyEmail@mega.nz"
            let mockSdk = MockPasswordRepositorySdk(
                _myEmail: expectedEmail,
                multiFactorCheckCompletion: requestDelegateFinished(
                    request: MockSdkRequest(flag: sdkFlag),
                    error: .apiOk
                )
            )
            let sut = makeSUT(sdk: mockSdk)

            let result = try await sut.isTwoFactorAuthenticationEnabled()

            #expect(mockSdk.multiFactorAuthCheckCalls == [expectedEmail])
            #expect(result == isTwoFAEnabled)
        }

        try await assert(whenSdkFlag: true, isTwoFAEnabled: true)
        try await assert(whenSdkFlag: false, isTwoFAEnabled: false)
    }

    @Test func testIsTwoFactorAuthEnabled_whenRequestFailed_shouldThrowError() async throws {
        let expectedError = MockSdkError.anyError
        let mockSdk = MockPasswordRepositorySdk(
            multiFactorCheckCompletion: requestDelegateFinished(
                error: expectedError
            )
        )
        let sut = makeSUT(sdk: mockSdk)

        await #expect(performing: {
            _ = try await sut.isTwoFactorAuthenticationEnabled()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func testChangePassword_whenRequestSucceed_shouldPassNewPassword_andNotThrowError() async throws {
        let newPassword = String.random()
        let mockSdk = MockPasswordRepositorySdk(
            changePasswordCompletion: requestDelegateFinished(error: .apiOk)
        )
        let sut = makeSUT(sdk: mockSdk)

        try await sut.changePassword(newPassword)

        #expect(mockSdk.changePasswordCalls.count == 1)
        #expect(mockSdk.changePasswordCalls.first?.oldPassword == nil)
        #expect(mockSdk.changePasswordCalls.first?.newPassword == newPassword)
    }

    @Test func testChangePassword_whenRequestFails_shouldThrowError() async throws {
        let expectedError = MockSdkError.anyError
        let mockSdk = MockPasswordRepositorySdk(
            changePasswordCompletion: requestDelegateFinished(error: expectedError)
        )
        let sut = makeSUT(sdk: mockSdk)

        await #expect(performing: {
            try await sut.changePassword(.random())
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func testMultiFactorChangePassword_whenRequestSucceed_shouldPassNewPasswordAndPin_andNotThrowError() async throws {
        let newPassword = String.random()
        let pin = String.random()
        let mockSdk = MockPasswordRepositorySdk(
            multiFactorChangePasswordCompletion: requestDelegateFinished(error: .apiOk)
        )
        let sut = makeSUT(sdk: mockSdk)

        try await sut.changePassword(newPassword, pin: pin)

        #expect(mockSdk.multiFactorChangePasswordCalls.count == 1)
        #expect(mockSdk.multiFactorChangePasswordCalls.first?.newPassword == newPassword)
        #expect(mockSdk.multiFactorChangePasswordCalls.first?.pin == pin)
    }

    @Test func testMultiFactorChangePassword_whenRequestFails_shouldThrowError() async throws {
        let expectedError = MockSdkError.anyError
        let mockSdk = MockPasswordRepositorySdk(
            multiFactorChangePasswordCompletion: requestDelegateFinished(error: expectedError)
        )
        let sut = makeSUT(sdk: mockSdk)

        await #expect(performing: {
            try await sut.changePassword(.random(), pin: .random())
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockPasswordRepositorySdk = MockPasswordRepositorySdk()
    ) -> PasswordRepository {
        PasswordRepository(sdk: sdk)
    }
}

private final class MockPasswordRepositorySdk: MEGASdk, @unchecked Sendable {
    var multiFactorAuthCheckCalls = [String]()
    var changePasswordCalls = [(oldPassword: String?, newPassword: String)]()
    var multiFactorChangePasswordCalls = [MultiFactorChangePasswordParam]()

    var _myEmail: String?
    var multiFactorCheckCompletion: RequestDelegateStub
    var changePasswordCompletion: RequestDelegateStub
    var multiFactorChangePasswordCompletion: RequestDelegateStub

    init(
        _myEmail: String? = "myEmail@mega.nz",
        multiFactorCheckCompletion: @escaping RequestDelegateStub = { _, _ in },
        changePasswordCompletion: @escaping RequestDelegateStub = { _, _ in },
        multiFactorChangePasswordCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self._myEmail = _myEmail
        self.multiFactorCheckCompletion = multiFactorCheckCompletion
        self.changePasswordCompletion = changePasswordCompletion
        self.multiFactorChangePasswordCompletion = multiFactorChangePasswordCompletion
        super.init()
    }

    override var myEmail: String? {
        _myEmail
    }

    override func multiFactorAuthCheck(
        withEmail email: String,
        delegate: MEGARequestDelegate
    ) {
        multiFactorAuthCheckCalls.append(email)
        multiFactorCheckCompletion(delegate, self)
    }

    override func changePassword(
        _ oldPassword: String?,
        newPassword: String,
        delegate: MEGARequestDelegate
    ) {
        changePasswordCalls.append((oldPassword, newPassword))
        changePasswordCompletion(delegate, self)
    }

    struct MultiFactorChangePasswordParam {
        let oldPassword: String?
        let newPassword: String
        let pin: String
    }

    override func multiFactorAuthChangePassword(
        _ oldPassword: String?,
        newPassword: String,
        pin: String,
        delegate: MEGARequestDelegate
    ) {
        multiFactorChangePasswordCalls.append(
            MultiFactorChangePasswordParam(
                oldPassword: oldPassword,
                newPassword: newPassword,
                pin: pin
            )
        )
        multiFactorChangePasswordCompletion(delegate, self)
    }
}
