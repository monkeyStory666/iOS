// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct CreateAccountRepositoryTests {
    @Test func createAccount_shouldCallSDK_andReturnNameOnSuccess() async throws {
        let expectedFirstName = String.random()
        let expectedLastName = String.random()
        let expectedEmail = String.random()
        let expectedPassword = String.random()
        let expectedNameFromSdk = String.random()
        let mockSdk = MockCreateAccountRepositorySdk(
            createAccountCompletion: requestDelegateFinished(
                request: MockSdkRequest(name: expectedNameFromSdk)
            )
        )
        let sut = CreateAccountRepository(sdk: mockSdk)

        let result = try await sut.createAccount(
            withFirstName: expectedFirstName,
            lastName: expectedLastName,
            email: expectedEmail,
            password: expectedPassword
        )

        #expect(mockSdk.createAccountCalls.count == 1)
        #expect(mockSdk.createAccountCalls.first?.firstName == expectedFirstName)
        #expect(mockSdk.createAccountCalls.first?.lastName == expectedLastName)
        #expect(mockSdk.createAccountCalls.first?.email == expectedEmail)
        #expect(mockSdk.createAccountCalls.first?.password == expectedPassword)
        #expect(result == expectedNameFromSdk)
    }

    @Test func createAccount_whenNameNil_shouldThrowError() async throws {
        let sut = CreateAccountRepository(
            sdk: MockCreateAccountRepositorySdk(
                createAccountCompletion: requestDelegateFinished(
                    request: MockSdkRequest(name: nil)
                )
            )
        )

        await #expect(
            performing: {
                _ = try await sut.createAccount(
                    withFirstName: .random(),
                    lastName: .random(),
                    email: .random(),
                    password: .random()
                )
            },
            throws: { error in
                isError(error, equalTo: SignUpErrorEntity.nameEmpty)
            }
        )
    }

    @Test(
        arguments: [
            (
                MockSdkError(type: .apiEExist),
                SignUpErrorEntity.emailAlreadyInUse
            ),
            (
                MockSdkError(type: .apiEAccess),
                SignUpErrorEntity.generic
            )
        ]
    ) func createAccount_onSdkError_shouldThrowError(
        arguments: (sdkError: MEGAError, expectedError: any Error)
    ) async throws {
        let sut = CreateAccountRepository(
            sdk: MockCreateAccountRepositorySdk(
                createAccountCompletion: requestDelegateFinished(
                    error: arguments.sdkError
                )
            )
        )

        await #expect(
            performing: {
                _ = try await sut.createAccount(
                    withFirstName: .random(),
                    lastName: .random(),
                    email: .random(),
                    password: .random()
                )
            },
            throws: { error in
                isError(error, equalTo: arguments.expectedError)
            }
        )
    }
}

private final class MockCreateAccountRepositorySdk: MEGASdk, @unchecked Sendable {
    var createAccountCalls: [(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    )] = []

    var createAccountCompletion: RequestDelegateStub

    init(
        createAccountCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self.createAccountCompletion = createAccountCompletion
        super.init()
    }

    override func createAccount(
        withEmail email: String,
        password: String,
        firstname: String,
        lastname: String,
        delegate: any MEGARequestDelegate
    ) {
        createAccountCalls.append((firstname, lastname, email, password))
        createAccountCompletion(delegate, self)
    }
}
