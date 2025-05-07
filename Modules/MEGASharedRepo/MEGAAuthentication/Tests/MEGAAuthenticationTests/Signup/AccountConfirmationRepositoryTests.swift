// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct AccountConfirmationRepositoryTests {
    @Test func resendSignUpLink_shouldCallSDK_andNotThrowOnSuccess() async throws {
        let expectedEmail = String.random()
        let expectedName = String.random()
        let sut = AccountConfirmationRepository(
            sdk: MockAccountRepositorySdk(
                resendSignupLinkCompletion: requestDelegateFinished()
            )
        )

        try await sut.resendSignUpLink(
            withEmail: expectedEmail,
            name: expectedName
        )
    }

    @Test(
        arguments: [
            (
                MockSdkError(type: .apiEExist),
                ResendSignupLinkError.emailAlreadyInUse
            ),
            (
                MockSdkError(type: .apiEFailed),
                ResendSignupLinkError.emailConfirmationAlreadyRequested
            ),
            (
                MockSdkError(type: .apiEAccess),
                ResendSignupLinkError.generic
            )
        ]
    ) func resendSignupLink_whenSDKError_shouldThrowError(
        arguments: (sdkError: MEGAError, expectedError: any Error)
    ) async throws {
        let sut = AccountConfirmationRepository(
            sdk: MockAccountRepositorySdk(
                resendSignupLinkCompletion: requestDelegateFinished(
                    error: arguments.sdkError
                )
            )
        )

        await #expect(
            performing: {
                try await sut.resendSignUpLink(
                    withEmail: .random(),
                    name: .random()
                )
            },
            throws: { error in
                isError(error, equalTo: arguments.expectedError)
            }
        )
    }

    @Test func cancelCreateAccount_shouldCallSDK() {
        let mockSdk = MockAccountRepositorySdk()
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        sut.cancelCreateAccount()

        #expect(mockSdk.cancelCreateAccountCallCount == 1)
    }

    @Test(
        arguments: [true, false]
    ) func querySignupLink_shouldCallSDK_andNotThrowOnSuccess(flag: Bool) async throws {
        let expectedLink = String.random()
        let mockSdk = MockAccountRepositorySdk(
            querySignupLinkCompletion: requestDelegateFinished(
                request: MockSdkRequest(flag: flag)
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        let result = try await sut.querySignupLink(with: expectedLink)

        #expect(mockSdk.querySignupLinkCalls == [expectedLink])
        #expect(result == flag)
    }

    @Test(
        arguments: [
            (
                MockSdkError(type: .apiEAccess),
                AccountVerificationError.loggedIntoDifferentAccount
            ),
            (
                MockSdkError(type: .apiEExpired),
                AccountVerificationError.alreadyVerifiedOrCanceled
            )
        ]
    ) func querySignupLink_whenSDKError_shouldThrowError(
        arguments: (sdkError: MEGAError, expectedError: any Error)
    ) async throws {
        let mockSdk = MockAccountRepositorySdk(
            querySignupLinkCompletion: requestDelegateFinished(
                error: arguments.sdkError
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        await #expect(
            performing: {
                _ = try await sut.querySignupLink(with: .random())
            },
            throws: { error in
                isError(error, equalTo: arguments.expectedError)
            }
        )
    }

    @Test(
        arguments: [
            MockSdkError(type: .apiEFailed),
            MockSdkError(type: .apiEBlocked),
            MockSdkError(type: .apiEExist)
        ]
    ) func querySignupLink_whenUnhandledSDKError_shouldThrowError(
        unhandledError: MEGAError
    ) async throws {
        let mockSdk = MockAccountRepositorySdk(
            querySignupLinkCompletion: requestDelegateFinished(
                error: unhandledError
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        await #expect(
            performing: {
                _ = try await sut.querySignupLink(with: .random())
            },
            throws: { error in
                isError(error, equalTo: unhandledError)
            }
        )
    }

    @Test(
        arguments: [true, false]
    ) func verifyAccount_shouldCallSDK_andNotThrowOnSuccess(flag: Bool) async throws {
        let expectedLink = String.random()
        let expectedPassword = String.random()
        let mockSdk = MockAccountRepositorySdk(
            confirmAccountCompletion: requestDelegateFinished(
                request: MockSdkRequest(flag: flag)
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        let result = try await sut.verifyAccount(
            with: expectedLink,
            password: expectedPassword
        )

        #expect(mockSdk.verifyAccountCalls.count == 1)
        #expect(mockSdk.verifyAccountCalls.first?.link == expectedLink)
        #expect(mockSdk.verifyAccountCalls.first?.password == expectedPassword)
        #expect(result == flag)
    }

    @Test(
        arguments: [
            (
                MockSdkError(type: .apiEAccess),
                AccountVerificationError.loggedIntoDifferentAccount
            ),
            (
                MockSdkError(type: .apiEExpired),
                AccountVerificationError.alreadyVerifiedOrCanceled
            )
        ]
    ) func verifyAccount_whenSDKError_shouldThrowError(
        arguments: (sdkError: MEGAError, expectedError: any Error)
    ) async throws {
        let mockSdk = MockAccountRepositorySdk(
            confirmAccountCompletion: requestDelegateFinished(
                error: arguments.sdkError
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        await #expect(
            performing: {
                _ = try await sut.verifyAccount(
                    with: .random(),
                    password: .random()
                )
            },
            throws: { error in
                isError(error, equalTo: arguments.expectedError)
            }
        )
    }

    @Test(
        arguments: [
            MockSdkError(type: .apiEFailed),
            MockSdkError(type: .apiEBlocked),
            MockSdkError(type: .apiEExist)
        ]
    ) func verifyAccount_whenUnhandledSDKError_shouldThrowError(
        unhandledError: MEGAError
    ) async throws {
        let mockSdk = MockAccountRepositorySdk(
            confirmAccountCompletion: requestDelegateFinished(
                error: unhandledError
            )
        )
        let sut = AccountConfirmationRepository(sdk: mockSdk)

        await #expect(
            performing: {
                _ = try await sut.verifyAccount(
                    with: .random(),
                    password: .random()
                )
            },
            throws: { error in
                isError(error, equalTo: unhandledError)
            }
        )
    }
}

private final class MockAccountRepositorySdk: MEGASdk, @unchecked Sendable {
    var resendSignupLinkCalls: [(
        email: String,
        name: String
    )] = []

    var verifyAccountCalls: [(
        link: String,
        password: String
    )] = []

    var querySignupLinkCalls: [String] = []

    var cancelCreateAccountCallCount = 0

    var resendSignupLinkCompletion: RequestDelegateStub
    var querySignupLinkCompletion: RequestDelegateStub
    var confirmAccountCompletion: RequestDelegateStub

    init(
        resendSignupLinkCompletion: @escaping RequestDelegateStub = { _, _ in },
        querySignupLinkCompletion: @escaping RequestDelegateStub = { _, _ in },
        confirmAccountCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self.resendSignupLinkCompletion = resendSignupLinkCompletion
        self.querySignupLinkCompletion = querySignupLinkCompletion
        self.confirmAccountCompletion = confirmAccountCompletion
        super.init()
    }

    override func resendSignupLink(
        withEmail email: String,
        name: String,
        delegate: any MEGARequestDelegate
    ) {
        resendSignupLinkCalls.append((email, name))
        resendSignupLinkCompletion(delegate, self)
    }

    override func cancelCreateAccount() {
        cancelCreateAccountCallCount += 1
    }

    override func querySignupLink(
        _ link: String,
        delegate: any MEGARequestDelegate
    ) {
        querySignupLinkCalls.append(link)
        querySignupLinkCompletion(delegate, self)
    }

    override func confirmAccount(
        withLink link: String,
        password: String,
        delegate: any MEGARequestDelegate
    ) {
        verifyAccountCalls.append((link, password))
        confirmAccountCompletion(delegate, self)
    }
}
