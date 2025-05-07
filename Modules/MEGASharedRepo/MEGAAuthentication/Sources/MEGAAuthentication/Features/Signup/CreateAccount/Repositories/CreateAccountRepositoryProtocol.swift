// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol CreateAccountRepositoryProtocol {
    func createAccount(
        withFirstName firstName: String, lastName: String, email: String, password: String
    ) async throws -> String
}
