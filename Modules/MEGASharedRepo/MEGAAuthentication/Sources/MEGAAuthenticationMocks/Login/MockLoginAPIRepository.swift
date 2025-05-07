// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Foundation
import MEGATest

public final class MockLoginAPIRepository:
    MockObject<MockLoginAPIRepository.Action>,
    LoginAPIRepositoryProtocol,
    @unchecked Sendable {
    public enum Action: Equatable {
        case login(username: String, password: String)
        case twoFactorLogin(username: String, password: String, pin: String)
        case fastLogin(
            timeout: TimeInterval?,
            session: String
        )
        case accountAuth
        case set(accountAuth: String?)
        case loadUserData
        case logout
        case resendVerificationEmail
        case fetchNodes
    }

    private let loginResult: Result<String, any Error>
    private let loadUserDataResult: Result<Void, any Error>
    private let accountAuthReturnValue: String?
    private let fetchNodesResult: Result<Void, any Error>

    public init(
        loginResult: Result<String, any Error> = .success(""),
        loadUserDataResult: Result<Void, any Error> = .success(()),
        accountAuthReturnValue: String? = nil,
        fetchNodes: Result<Void, any Error> = .success(())
    ) {
        self.loginResult = loginResult
        self.loadUserDataResult = loadUserDataResult
        self.accountAuthReturnValue = accountAuthReturnValue
        self.fetchNodesResult = fetchNodes

        super.init()
    }

    public func login(with username: String, and password: String) async throws -> String {
        actions.append(.login(username: username, password: password))
        return try loginResult.get()
    }

    public func login(with username: String, and password: String, pin: String) async throws -> String {
        actions.append(.twoFactorLogin(username: username, password: password, pin: pin))
        return try loginResult.get()
    }

    public func fastLogin(
        with timeout: TimeInterval?,
        session: String
    ) async throws -> String {
        actions.append(.fastLogin(timeout: timeout, session: session))
        return try loginResult.get()
    }

    public func accountAuth() -> String? {
        actions.append(.accountAuth)
        return accountAuthReturnValue
    }

    public func set(accountAuth: String?) {
        actions.append(.set(accountAuth: accountAuth))
    }

    public func loadUserData() async throws {
        actions.append(.loadUserData)
        try loadUserDataResult.get()
    }

    public func logout() async {
        actions.append(.logout)
    }

    public func resendVerificationEmail() {
        actions.append(.resendVerificationEmail)
    }

    public func fetchNodes() async throws {
        actions.append(.fetchNodes)
        try fetchNodesResult.get()
    }

    // MARK: - Helpers

    private func parseLoginResult() throws -> String {
        switch loginResult {
        case .success(let session):
            return session
        case .failure(let error):
            throw error
        }
    }
}
