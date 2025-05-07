// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol LoginAPIRepositoryProtocol: Sendable {
    func login(with username: String, and password: String) async throws -> String
    func login(with username: String, and password: String, pin: String) async throws -> String
    func fastLogin(with timeout: TimeInterval?, session: String) async throws -> String
    func accountAuth() -> String?
    func set(accountAuth: String?)
    func loadUserData() async throws
    func logout() async
    func resendVerificationEmail()
    func fetchNodes() async throws
}

public extension LoginAPIRepositoryProtocol {
    func fastLogin(with session: String) async throws -> String {
        try await fastLogin(with: nil, session: session)
    }
}
