// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift

public protocol LoginUseCaseProtocol: Sendable {
    func login(with username: String, and password: String) async throws
    func login(with username: String, and password: String, pin: String) async throws
    func loginSession() async -> LoginSession?
    func hasLoggedIn() -> Bool
    func resendVerificationEmail()
}

public enum LoginSession: Sendable {
    case old
    case renewed
}

public final class LoginUseCase: LoginUseCaseProtocol {
    private let fetchNodesEnabled: Bool
    private let shouldIncludeFastLoginTimeout: Bool
    private let updateDuplicateSession: Bool
    private let loginAPIRepository: any LoginAPIRepositoryProtocol
    private let loginStoreRepository: any LoginStoreRepositoryProtocol

    public init(
        fetchNodesEnabled: Bool,
        shouldIncludeFastLoginTimeout: Bool,
        updateDuplicateSession: Bool,
        loginAPIRepository: some LoginAPIRepositoryProtocol,
        loginStoreRepository: some LoginStoreRepositoryProtocol
    ) {
        self.fetchNodesEnabled = fetchNodesEnabled
        self.shouldIncludeFastLoginTimeout = shouldIncludeFastLoginTimeout
        self.updateDuplicateSession = updateDuplicateSession
        self.loginAPIRepository = loginAPIRepository
        self.loginStoreRepository = loginStoreRepository
    }

    public func login(with username: String, and password: String) async throws {
        let session = try await loginAPIRepository.login(
            with: username.trimmingCharacters(in: .whitespacesAndNewlines),
            and: password
        )

        try await login(with: session)
    }

    public func login(with username: String, and password: String, pin: String) async throws {
        let session = try await loginAPIRepository.login(
            with: username.trimmingCharacters(in: .whitespacesAndNewlines),
            and: password,
            pin: pin
        )

        try await login(with: session)
    }

    public func loginSession() async -> LoginSession? {
        guard let session = try? loginStoreRepository.session() else {
            return nil
        }

        do {
            let renewedSession: String

            if shouldIncludeFastLoginTimeout {
                renewedSession = try await loginAPIRepository.fastLogin(with: 5, session: session)
            } else {
                renewedSession = try await loginAPIRepository.fastLogin(with: session)
            }

            try await login(with: renewedSession)
            return .renewed
        } catch LoginErrorEntity.badSession {
            return nil
        } catch {
            return .old
        }
    }

    public func hasLoggedIn() -> Bool {
        (try? loginStoreRepository.session()) != nil
    }

    public func resendVerificationEmail() {
        loginAPIRepository.resendVerificationEmail()
    }

    // MARK: - Helpers

    private func login(with session: String) async throws {
        try loginStoreRepository.set(
            session: session,
            updateDuplicateSession: updateDuplicateSession
        )
        loginAPIRepository.set(accountAuth: loginAPIRepository.accountAuth())
        try await loadUserData()
        try await fetchNodes()
    }

    /// Required to start receiving action packages. It's recommended to notify the API developer
    /// if a certain client type wants to receive action packages without fetching all the nodes, they
    /// can setup a minimal client flag so it only execute minimal fetch.
    ///
    /// Make sure to setup the correct client type in the SDK before calling this method.
    private func fetchNodes() async throws {
        guard fetchNodesEnabled else { return }

        try await loginAPIRepository.fetchNodes()
    }

    private func loadUserData() async throws {
        do {
            try await loginAPIRepository.loadUserData()
        } catch {
            if isError(error, equalTo: LoginErrorEntity.accountSuspended(nil)) {
                // If an account gets suspended, it'll be able to successfully login (creating a session) but it'll receive
                // an EBLOCKED error when we try to load the user's data. The created session is actually an invalid one
                // (it can causes crashes if we try to use it) so we need to wipe out the keychain before proceeding
                try loginStoreRepository.delete()
            }
            throw error
        }
    }
}
