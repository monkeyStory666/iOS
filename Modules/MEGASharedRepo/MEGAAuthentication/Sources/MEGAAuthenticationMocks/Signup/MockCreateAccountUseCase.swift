// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockCreateAccountUseCase:
    MockObject<MockCreateAccountUseCase.Action>,
    CreateAccountUseCaseProtocol,
    @unchecked Sendable {
    public enum Action: Equatable {
        case createAccount(firstName: String, lastName: String, email: String, password: String)
    }

    private let createAccountResult: Result<String, any Error>

    public init(createAccountResult: Result<String, any Error> = .success("")) {
        self.createAccountResult = createAccountResult
        super.init()
    }

    public func createAccount(
        withFirstName firstName: String, lastName: String, email: String, password: String
    ) async throws -> String {
        actions.append(
            .createAccount(firstName: firstName, lastName: lastName, email: email, password: password)
        )

        return try createAccountResult.get()
    }
}
