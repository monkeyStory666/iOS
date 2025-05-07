// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol CreateAccountUseCaseProtocol {
    func createAccount(
        withFirstName firstName: String, lastName: String, email: String, password: String
    ) async throws -> String
}

public final class CreateAccountUseCase: CreateAccountUseCaseProtocol {
    private let repository: any CreateAccountRepositoryProtocol

    public init(repository: some CreateAccountRepositoryProtocol) {
        self.repository = repository
    }

    public func createAccount(
        withFirstName firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> String {
        try await repository.createAccount(
            withFirstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
    }
}
