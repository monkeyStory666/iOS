// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGAInfrastructure
import MEGAPresentation
import MEGATest
import Testing

struct LoginUseCaseTests {
    private enum LoginMethodOption {
        case singleFactor
        case twoFactor
    }

    private struct TestDependencies {
        let sut: LoginUseCase
        let loginAPIRepository: MockLoginAPIRepository
        let loginStoreRepository: MockLoginStoreRepository
    }

    @Test func testLoginSession_onErrorWhenGettingSessionFromStore_shouldReturnNil() async {
        await assertLoginSession(
            shouldBe: nil,
            loginStoreRepository: MockLoginStoreRepository(
                returnSessionInformationResult: .failure(ErrorInTest())
            ),
            assertAlso: { loginStoreRepository, loginAPIRepository in
                loginStoreRepository.swt.assert(.session, isCalled: .once)
                loginAPIRepository.swt.assertActions(shouldBe: [])
            }
        )
    }

    @Test func testLoginSession_onErrorWhenLogin_shouldReturnOld() async {
        await assertLoginSession(
            shouldBe: .old,
            loginStoreRepository: MockLoginStoreRepository(
                returnSessionInformationResult: .success("Session")
            ),
            loginAPIRepository: MockLoginAPIRepository(loginResult: .failure(ErrorInTest())),
            assertAlso: { _, loginAPIRepository in
                loginAPIRepository.swt.assertActions(shouldBe: [
                    .fastLogin(timeout: nil, session: "Session")
                ])
            }
        )
    }

    @Test func testLoginSession_onErrorWhenSettingSession_shouldReturnOld() async {
        await assertLoginSession(
            shouldBe: .old,
            loginStoreRepository: MockLoginStoreRepository(
                setSessionInformationResult: .failure(ErrorInTest()),
                returnSessionInformationResult: .success("Session")
            ),
            loginAPIRepository: MockLoginAPIRepository(loginResult: .failure(ErrorInTest())),
            assertAlso: { _, loginAPIRepository in
                loginAPIRepository.swt.assertActions(shouldBe: [
                    .fastLogin(timeout: nil, session: "Session")
                ])
            }
        )
    }

    @Test func testLoginSession_onErrorWhenLoadingUserData_shouldReturnOld() async {
        await assertLoginSession(
            shouldBe: .old,
            loginStoreRepository: MockLoginStoreRepository(
                returnSessionInformationResult: .success("Session")
            ),
            loginAPIRepository: MockLoginAPIRepository(
                loadUserDataResult: .failure(ErrorInTest()),
                accountAuthReturnValue: "Auth"
            ),
            assertAlso: { _, loginAPIRepository in
                loginAPIRepository.swt.assert(.set(accountAuth: "Auth"), isCalled: .once)
                loginAPIRepository.swt.assert(
                    .fastLogin(timeout: nil, session: "Session"),
                    isCalled: .once
                )
            }
        )
    }

    @Test func testLoginSession_whenAPIBadSessionError_shouldReturnNil() async {
        await assertLoginSession(
            shouldBe: nil,
            loginStoreRepository: MockLoginStoreRepository(
                returnSessionInformationResult: .success("Session")
            ),
            loginAPIRepository: MockLoginAPIRepository(
                loginResult: .failure(LoginErrorEntity.badSession),
                accountAuthReturnValue: "Auth"
            ),
            assertAlso: { loginStoreRepository, loginAPIRepository in
                loginAPIRepository.swt.assertActions(shouldBe: [
                    .fastLogin(timeout: nil, session: "Session")
                ])
            }
        )
    }

    @Test func testLoginSession_whenSuccessful_shouldReturnRenewed() async {
        await assertLoginSession(
            shouldBe: .renewed,
            loginStoreRepository: MockLoginStoreRepository(
                returnSessionInformationResult: .success("Session")
            ),
            loginAPIRepository: MockLoginAPIRepository(
                loginResult: .success("RenewedSession"),
                accountAuthReturnValue: "Auth"
            ),
            assertAlso: { loginStoreRepository, loginAPIRepository in
                loginStoreRepository.swt.assert(
                    .set(
                        session: "RenewedSession",
                        updateDuplicateSession: false
                    ),
                    isCalled: .once
                )
                loginAPIRepository.swt.assert(.set(accountAuth: "Auth"), isCalled: .once)
                loginAPIRepository.swt.assert(
                    .fastLogin(timeout: nil, session: "Session"),
                    isCalled: .once
                )
                loginAPIRepository.swt.assert(.loadUserData, isCalled: .once)
            }
        )
    }

    @Test func testLogin_withAPIError_shouldThrowError() async {
        await assertLogin_withAPIError_shouldThrowError(with: .singleFactor)
    }

    @Test func testLogin_whenSuspendedErrorThrown_afterLoadUserData_shouldDeleteFromStore() async {
        let mockLoginStoreRepo = MockLoginStoreRepository()
        let sut = makeSUT(
            loginAPIRepository: MockLoginAPIRepository(
                loadUserDataResult: .failure(
                    LoginErrorEntity.accountSuspended(.copyright)
                )
            ),
            loginStoreRepository: mockLoginStoreRepo
        )

        do {
            try await sut.login(with: "username", and: "password")
            Issue.record("Expected to throw the account suspended error")
        } catch {
            mockLoginStoreRepo.swt.assert(.delete, isCalled: .once)
        }
    }

    @Test func testLogin_withStoringSessionError_shouldThrowError() async {
        await assertLogin_withStoringSessionError_shouldThrowError(with: .singleFactor)
    }

    @Test func testLogin_whenSuccess_shouldNotThrowError() async throws {
        try await assertLogin_whenSuccess_shouldNotThrowError(with: .singleFactor)
    }

    @Test func testLoginWithPin_withAPIError_shouldThrowError() async {
        await assertLogin_withAPIError_shouldThrowError(with: .twoFactor)
    }

    @Test func testLoginWithPin_withStoringSessionError_shouldThrowError() async {
        await assertLogin_withStoringSessionError_shouldThrowError(with: .twoFactor)
    }

    @Test func testLoginWithPin_whenSuccess_shouldNotThrowError() async throws {
        try await assertLogin_whenSuccess_shouldNotThrowError(with: .twoFactor)
    }

    @Test func testLoginResendEmail_shouldCallRepositoryMethod() async throws {
        let dependencies = makeSUTWithRepositories()
        let sut = dependencies.sut
        let loginAPIRepository = dependencies.loginAPIRepository

        sut.resendVerificationEmail()

        assertLoginAPIRepositoryInvocation(for: .resendVerificationEmail, and: loginAPIRepository)
    }

    @Test func testLogin_shouldTrimWhitespacesFromUsername() async throws {
        let dependencies = makeSUTWithRepositories()
        let sut = dependencies.sut
        let loginAPIRepository = dependencies.loginAPIRepository

        try await sut.login(with: "   username   ", and: "password")

        loginAPIRepository.swt.assert(
            .login(username: "username", password: "password"),
            isCalled: .once
        )
    }

    @Test func testTwoFactorLogin_shouldTrimWhitespacesFromUsername() async throws {
        let dependencies = makeSUTWithRepositories()
        let sut = dependencies.sut
        let loginAPIRepository = dependencies.loginAPIRepository

        try await sut.login(with: "   username   ", and: "password", pin: "123")

        loginAPIRepository.swt.assert(
            .twoFactorLogin(username: "username", password: "password", pin: "123"),
            isCalled: .once
        )
    }

    @Test func testLogin_shouldFetchNodes() async throws {
        try await assertLogin_whenSuccess(
            with: .singleFactor,
            fetchNodesEnabled: true,
            shouldCallFetchNodes: .once
        )
        try await assertLogin_whenSuccess(
            with: .singleFactor,
            fetchNodesEnabled: false,
            shouldCallFetchNodes: 0.times
        )
        try await assertLogin_whenSuccess(
            with: .twoFactor,
            fetchNodesEnabled: true,
            shouldCallFetchNodes: .once
        )
        try await assertLogin_whenSuccess(
            with: .twoFactor,
            fetchNodesEnabled: false,
            shouldCallFetchNodes: 0.times
        )
    }

    @Test func testLoginSession_callsFastLoginWithTimeout_whenFastLoginTimeoutIsEnabled() async throws {
        let mockLoginRepository = MockLoginAPIRepository(loginResult: .success("Session"))
        let loginStoreRepository = MockLoginStoreRepository(
            returnSessionInformationResult: .success("Session")
        )

        let sut = makeSUT(
            shouldIncludeFastLoginTimeout: true,
            loginAPIRepository: mockLoginRepository,
            loginStoreRepository: loginStoreRepository
        )
        _ = await sut.loginSession()

        mockLoginRepository.swt.assert(.fastLogin(timeout: 5.0, session: "Session"), isCalled: .once)
    }

    @Test func loginSession_whenUpdateDuplicateSessionIsTrue_shouldUpdateDuplicateSession() async throws {
        let mockLoginRepository = MockLoginAPIRepository(loginResult: .success("Session"))
        let loginStoreRepository = MockLoginStoreRepository(
            returnSessionInformationResult: .success("Session")
        )
        let sut = makeSUT(
            updateDuplicateSession: true,
            loginAPIRepository: mockLoginRepository,
            loginStoreRepository: loginStoreRepository
        )

        try await invokeLogin(with: .singleFactor, sut: sut)

        loginStoreRepository.swt.assert(
            .set(session: "Session", updateDuplicateSession: true),
            isCalled: .once
        )
    }

    // MARK: - Helpers

    private func assertLogin_withAPIError_shouldThrowError(
        with loginMethodOption: LoginMethodOption
    ) async {
        let testDependencies = makeSUTWithRepositories(loginResult: .failure(ErrorInTest()))
        await assertLogin_withError(
            with: loginMethodOption, testDependencies: testDependencies, setSessionFrequency: 0.times
        )
    }

    private func assertLogin_withStoringSessionError_shouldThrowError(
        with loginMethodOption: LoginMethodOption
    ) async {
        let testDependencies = makeSUTWithRepositories(
            setSessionInformationResult: .failure(ErrorInTest())
        )
        await assertLogin_withError(
            with: loginMethodOption, testDependencies: testDependencies, setSessionFrequency: .once
        )
    }

    private func assertLogin_withError(
        with loginMethodOption: LoginMethodOption,
        testDependencies: TestDependencies,
        setSessionFrequency: CallFrequency
    ) async {
        let sut = testDependencies.sut
        let loginAPIRepository = testDependencies.loginAPIRepository
        let loginStoreRepository = testDependencies.loginStoreRepository

        do {
            try await invokeLogin(with: loginMethodOption, sut: sut)
            Issue.record("Login should not succeed")
        } catch {
            assertLoginAPIInvocation(with: loginMethodOption, and: loginAPIRepository)
            loginStoreRepository.swt.assert(
                .set(session: "", updateDuplicateSession: false),
                isCalled: setSessionFrequency
            )
            loginAPIRepository.swt.assert(.set(accountAuth: "Auth"), isCalled: 0.times)
            loginAPIRepository.swt.assert(.loadUserData, isCalled: 0.times)
        }
    }

    private func assertLogin_whenSuccess_shouldNotThrowError(
        with loginMethodOption: LoginMethodOption
    ) async throws {
        let testDependencies = makeSUTWithRepositories()
        let sut = testDependencies.sut
        let loginAPIRepository = testDependencies.loginAPIRepository
        let loginStoreRepository = testDependencies.loginStoreRepository

        try await invokeLogin(with: loginMethodOption, sut: sut)
        assertLoginAPIInvocation(with: loginMethodOption, and: loginAPIRepository)
        loginStoreRepository.swt.assert(.set(session: "", updateDuplicateSession: false), isCalled: .once)
        loginAPIRepository.swt.assert(.set(accountAuth: "Auth"), isCalled: .once)
        loginAPIRepository.swt.assert(.loadUserData, isCalled: .once)
    }

    private func assertLogin_whenSuccess(
        with loginMethodOption: LoginMethodOption,
        fetchNodesEnabled: Bool,
        shouldCallFetchNodes expectedFetchNodeCalls: CallFrequency
    ) async throws {
        let mockLoginAPIRepo = MockLoginAPIRepository()
        let sut = makeSUT(
            fetchNodesEnabled: fetchNodesEnabled,
            loginAPIRepository: mockLoginAPIRepo
        )

        try await invokeLogin(with: loginMethodOption, sut: sut)

        mockLoginAPIRepo.swt.assert(.fetchNodes, isCalled: expectedFetchNodeCalls)
    }

    private func invokeLogin(with loginMethodOption: LoginMethodOption, sut: LoginUseCase) async throws {
        switch loginMethodOption {
        case .singleFactor:
            try await sut.login(with: "username", and: "password")
        case .twoFactor:
            try await sut.login(with: "username", and: "password", pin: "123")
        }
    }

    private func assertLoginAPIInvocation(
        with loginMethodOption: LoginMethodOption,
        and loginAPIRepository: MockLoginAPIRepository
    ) {
        let action: MockLoginAPIRepository.Action
        switch loginMethodOption {
        case .singleFactor:
            action = .login(username: "username", password: "password")
        case .twoFactor:
            action = .twoFactorLogin(username: "username", password: "password", pin: "123")
        }
        loginAPIRepository.swt.assert(action, isCalled: .once)
    }

    private func assertLoginSession(
        shouldBe expectedResult: LoginSession?,
        loginStoreRepository: MockLoginStoreRepository = MockLoginStoreRepository(),
        loginAPIRepository: MockLoginAPIRepository = MockLoginAPIRepository(),
        assertAlso otherAssertions: (
            _ loginStore: MockLoginStoreRepository,
            _ loginApi: MockLoginAPIRepository
        ) -> Void
    ) async {
        let sut = makeSUT(
            loginAPIRepository: loginAPIRepository,
            loginStoreRepository: loginStoreRepository
        )

        let result = await sut.loginSession()
        #expect(result == expectedResult)

        loginStoreRepository.swt.assert(
            .session,
            isCalled: .once
        )
        otherAssertions(loginStoreRepository, loginAPIRepository)
    }

    private func assertLoginAPIRepositoryInvocation(
        for action: MockLoginAPIRepository.Action,
        and loginAPIRepository: MockLoginAPIRepository
    ) {
        loginAPIRepository.swt.assert(action, isCalled: .once)
    }

    private func assertLoginStoreRepositoryInvocation(
        for action: MockLoginStoreRepository.Action,
        and loginStoreRepository: MockLoginStoreRepository
    ) {
        loginStoreRepository.swt.assert(action, isCalled: .once)
    }

    private func makeSUTWithRepositories(
        loginResult: Result<String, any Error> = .success(""),
        setSessionInformationResult: Result<Void, any Error> = .success(())
    ) -> TestDependencies {
        let loginAPIRepository = MockLoginAPIRepository(loginResult: loginResult, accountAuthReturnValue: "Auth")
        let loginStoreRepository = MockLoginStoreRepository(setSessionInformationResult: setSessionInformationResult)
        let sut = makeSUT(
            loginAPIRepository: loginAPIRepository, loginStoreRepository: loginStoreRepository
        )
        return TestDependencies(
            sut: sut, loginAPIRepository: loginAPIRepository, loginStoreRepository: loginStoreRepository
        )
    }

    private func makeSUT(
        fetchNodesEnabled: Bool = false,
        shouldIncludeFastLoginTimeout: Bool = false,
        updateDuplicateSession: Bool = false,
        loginAPIRepository: some LoginAPIRepositoryProtocol = MockLoginAPIRepository(),
        loginStoreRepository: some LoginStoreRepositoryProtocol = MockLoginStoreRepository()
    ) -> LoginUseCase {
        LoginUseCase(
            fetchNodesEnabled: fetchNodesEnabled,
            shouldIncludeFastLoginTimeout: shouldIncludeFastLoginTimeout,
            updateDuplicateSession: updateDuplicateSession,
            loginAPIRepository: loginAPIRepository,
            loginStoreRepository: loginStoreRepository
        )
    }
}
