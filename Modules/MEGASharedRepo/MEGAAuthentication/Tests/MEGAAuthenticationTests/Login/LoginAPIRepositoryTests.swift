// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGATest
import MEGASwift
import Testing

struct LoginAPIRepositoryTests {
    @Test func login_shouldCallSdk_andReturnSession() async throws {
        let expectedSession = String.random()
        let mockSdk = MockLoginSdk(
            dumpSession: expectedSession,
            loginCompletion: requestDelegateFinished()
        )
        let sut = LoginAPIRepository(sdk: mockSdk)

        #expect(
            try await sut.login(
                with: "username",
                and: "password"
            ) == expectedSession
        )
        #expect(mockSdk.loginCalls.count == 1)
        #expect(mockSdk.loginCalls.first?.email == "username")
        #expect(mockSdk.loginCalls.first?.password == "password")
    }

    @Test func login_whenDumpSessionNil_shouldThrowError() async {
        let sut = LoginAPIRepository(
            sdk: MockLoginSdk(
                dumpSession: nil,
                loginCompletion: requestDelegateFinished()
            )
        )

        await #expect(
            performing: {
                _ = try await sut.login(
                    with: "username",
                    and: "password"
                )
            },
            throws: { error in
                isError(error, equalTo: LoginErrorEntity.generic)
            }
        )
    }

    @Test(
        arguments: [
            (
                MockSdkError(type: .apiEMFARequired),
                LoginErrorEntity.twoFactorAuthenticationRequired
            ),
            (
                MockSdkError(type: .apiEIncomplete),
                LoginErrorEntity.accountNotValidated
            ),
            (
                MockSdkError(type: .apiESid),
                LoginErrorEntity.badSession
            ),
            (
                MockSdkError(type: .apiETooMany),
                LoginErrorEntity.tooManyAttempts
            ),
            (
                MockSdkError(type: .apiEAccess),
                LoginErrorEntity.generic
            )
        ]
    ) func login_whenSDKError_shouldThrowError(
        arguments: (sdkError: MEGAError, expectedError: any Error)
    ) async throws {
        let sut = LoginAPIRepository(
            sdk: MockLoginSdk(
                loginCompletion: requestDelegateFinished(
                    error: arguments.sdkError
                )
            )
        )

        await #expect(
            performing: {
                _ = try await sut.login(
                    with: "username",
                    and: "password"
                )
            },
            throws: { error in
                isError(error, equalTo: arguments.expectedError)
            }
        )
    }

    @Test func login_with2FAPin_shouldCallSdk_andReturnSession() async throws {
        let expectedSession = String.random()
        let mockSdk = MockLoginSdk(
            dumpSession: expectedSession,
            multiFALoginCompletion: requestDelegateFinished()
        )
        let sut = LoginAPIRepository(sdk: mockSdk)

        #expect(
            try await sut.login(
                with: "username",
                and: "password",
                pin: "123456"
            ) == expectedSession
        )
        #expect(mockSdk.multiFactorAuthLoginCalls.count == 1)
        #expect(mockSdk.multiFactorAuthLoginCalls.first?.email == "username")
        #expect(mockSdk.multiFactorAuthLoginCalls.first?.password == "password")
        #expect(mockSdk.multiFactorAuthLoginCalls.first?.pin == "123456")
    }

    @Test func login_with2FAPin_whenNoEntError_shouldNotThrow() async throws {
        let expectedSession = String.random()
        let mockSdk = MockLoginSdk(
            dumpSession: expectedSession,
            multiFALoginCompletion: requestDelegateFinished(
                error: MockSdkError(type: .apiENoent)
            )
        )
        let sut = LoginAPIRepository(sdk: mockSdk)

        #expect(
            try await sut.login(
                with: "username",
                and: "password",
                pin: "123456"
            ) == expectedSession
        )
    }

    @Test func fastLogin_shouldCallSDK_andReturnSession() async throws {
        let oldSession = String.random()
        let expectedSession = String.random()
        let mockSdk = MockLoginSdk(
            dumpSession: expectedSession,
            fastLoginCompletion: requestDelegateFinished()
        )
        let sut = LoginAPIRepository(sdk: mockSdk)

        #expect(try await sut.fastLogin(with: oldSession) == expectedSession)
        #expect(mockSdk.fastLoginCalls == [oldSession])
    }

    @Test func accountAuth_shouldCallSDK() async throws {
        let expectedAccountAuth = String.random()
        let sut = LoginAPIRepository(sdk: MockLoginSdk(accountAuth: expectedAccountAuth))

        #expect(sut.accountAuth() == expectedAccountAuth)
    }

    @Test func setAccountAuth_shouldCallSDK() {
        let expectedAccountAuth = String.random()
        let mockSdk = MockLoginSdk()
        let sut = LoginAPIRepository(sdk: mockSdk)

        sut.set(accountAuth: expectedAccountAuth)

        #expect(mockSdk.setAccountAuthCalls == [expectedAccountAuth])
    }

    @Test func loadUserData_shouldCallSDK_andNotThrowWhenSuccess() async throws {
        let mockSdk = MockLoginSdk(getUserDataCompletion: requestDelegateFinished())
        let sut = LoginAPIRepository(sdk: mockSdk)

        try await sut.loadUserData()
    }

    @Test func loadUserData_whenError_shouldThrow() async {
        let sut = LoginAPIRepository(
            sdk: MockLoginSdk(
                getUserDataCompletion: requestDelegateFinished(
                    error: MockSdkError.anyError
                )
            )
        )

        await #expect(
            performing: {
                try await sut.loadUserData()
            },
            throws: { error in
                isError(error, equalTo: LoadUserDataErrorEntity.generic)
            }
        )
    }

    @Test func logout_shouldCallSDK() async {
        let mockSdk = MockLoginSdk()
        let sut = LoginAPIRepository(sdk: mockSdk)

        await sut.logout()

        #expect(mockSdk.logoutCallCount == 1)
    }

    @Test func resendVerificationEmail_shouldCallSDK() {
        let mockSdk = MockLoginSdk()
        let sut = LoginAPIRepository(sdk: mockSdk)

        sut.resendVerificationEmail()

        #expect(mockSdk.resendVerificationEmailCallCount == 1)
    }

    @Test func fetchNodes_shouldCallSDK_andNotThrowWhenSuccess() async throws {
        let mockSdk = MockLoginSdk(fetchNodesCompletion: requestDelegateFinished())
        let sut = LoginAPIRepository(sdk: mockSdk)

        try await sut.fetchNodes()
    }

    @Test func fetchNodes_whenError_shouldThrow() async {
        let expectedError = MockSdkError(type: .apiEAccess)
        let sut = LoginAPIRepository(
            sdk: MockLoginSdk(
                fetchNodesCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(
            performing: {
                try await sut.fetchNodes()
            },
            throws: { error in
                isError(error, equalTo: expectedError)
            }
        )
    }
}

private final class MockLoginSdk: MEGASdk, @unchecked Sendable {
    var loginCalls: [(
        email: String,
        password: String
    )] = []

    var multiFactorAuthLoginCalls: [(
        email: String,
        password: String,
        pin: String
    )] = []

    var fastLoginCalls: [String] = []
    var setAccountAuthCalls: [String?] = []
    var logoutCallCount = 0
    var resendVerificationEmailCallCount = 0

    var _dumpSession: String?
    var _accountAuth: String?

    var loginCompletion: RequestDelegateStub
    var multiFALoginCompletion: RequestDelegateStub
    var fastLoginCompletion: RequestDelegateStub
    var getUserDataCompletion: RequestDelegateStub
    var fetchNodesCompletion: RequestDelegateStub

    init(
        dumpSession: String? = "",
        accountAuth: String? = "",
        loginCompletion: @escaping RequestDelegateStub = { _, _ in },
        multiFALoginCompletion: @escaping RequestDelegateStub = { _, _ in },
        fastLoginCompletion: @escaping RequestDelegateStub = { _, _ in },
        getUserDataCompletion: @escaping RequestDelegateStub = { _, _ in },
        fetchNodesCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self._dumpSession = dumpSession
        self._accountAuth = accountAuth
        self.loginCompletion = loginCompletion
        self.multiFALoginCompletion = multiFALoginCompletion
        self.fastLoginCompletion = fastLoginCompletion
        self.getUserDataCompletion = getUserDataCompletion
        self.fetchNodesCompletion = fetchNodesCompletion
        super.init()
    }

    override func dumpSession() -> String? {
        _dumpSession
    }

    override func login(
        withEmail email: String,
        password: String,
        delegate: any MEGARequestDelegate
    ) {
        loginCalls.append((email, password))
        loginCompletion(delegate, self)
    }

    override func multiFactorAuthLogin(
        withEmail email: String,
        password: String,
        pin: String,
        delegate: any MEGARequestDelegate
    ) {
        multiFactorAuthLoginCalls.append((email, password, pin))
        multiFALoginCompletion(delegate, self)
    }

    override func fastLogin(withSession session: String, delegate: any MEGARequestDelegate) {
        fastLoginCalls.append(session)
        fastLoginCompletion(delegate, self)
    }

    override func accountAuth() -> String? {
        return _accountAuth
    }

    override func setAccountAuth(_ accountAuth: String?) {
        setAccountAuthCalls.append(accountAuth)
    }

    override func getUserData(with delegate: any MEGARequestDelegate) {
        getUserDataCompletion(delegate, self)
    }

    override func logout() {
        logoutCallCount += 1
    }

    override func resendVerificationEmail() {
        resendVerificationEmailCallCount += 1
    }

    override func fetchNodes(with delegate: any MEGARequestDelegate) {
        fetchNodesCompletion(delegate, self)
    }
}
