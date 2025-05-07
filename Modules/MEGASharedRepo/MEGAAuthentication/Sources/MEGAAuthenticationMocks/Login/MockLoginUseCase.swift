// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockLoginUseCase:
    MockObject<MockLoginUseCase.Action>,
    LoginUseCaseProtocol,
    @unchecked Sendable {
    public enum Action: Equatable {
        case login(username: String, password: String)
        case twoFactorLogin(username: String, password: String, pin: String)
        case loginSession
        case hasLoggedIn
        case resendVerificationEmail
    }

    private let loginResult: Result<Void, any Error>
    private let _loginSession: LoginSession?

    public init(
        loginResult: Result<Void, any Error> = .success(()),
        loginSession: LoginSession? = .renewed
    ) {
        self.loginResult = loginResult
        self._loginSession = loginSession

        super.init()
    }

    public func login(with username: String, and password: String) async throws {
        actions.append(.login(username: username, password: password))
        return try loginResult.get()
    }

    public func login(with username: String, and password: String, pin: String) async throws {
        actions.append(.twoFactorLogin(username: username, password: password, pin: pin))
        return try loginResult.get()
    }

    public func loginSession() async -> LoginSession? {
        actions.append(.loginSession)
        return _loginSession
    }

    public func hasLoggedIn() -> Bool {
        actions.append(.hasLoggedIn)
        return _loginSession != nil
    }

    public func resendVerificationEmail() {
        actions.append(.resendVerificationEmail)
    }
}
