// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol AccountConfirmationUseCaseProtocol {
    func resendSignUpLink(withEmail email: String, name: String) async throws
    func cancelCreateAccount()
    func waitForAccountConfirmationEvent() async
    func verifyAccount(
        with confirmationLinkUrl: String
    ) async throws -> Bool
}

public final class AccountConfirmationUseCase: AccountConfirmationUseCaseProtocol {
    private let repository: any AccountConfirmationRepositoryProtocol

    public init(repository: some AccountConfirmationRepositoryProtocol) {
        self.repository = repository
    }

    public func resendSignUpLink(withEmail email: String, name: String) async throws {
        try await repository.resendSignUpLink(withEmail: email, name: name)
    }

    public func cancelCreateAccount() {
        repository.cancelCreateAccount()
    }

    public func waitForAccountConfirmationEvent() async {
        await repository.waitForAccountConfirmationEvent()
    }

    public func verifyAccount(
        with confirmationLinkUrl: String
    ) async throws -> Bool {
        try await repository.querySignupLink(
            with: validatedLink(from: confirmationLinkUrl)
        )
    }

    private func validatedLink(from confirmationLinkUrl: String) -> String {
        confirmationLinkUrl.replacingOccurrences(of: "/confirm", with: "/#confirm")
    }
}
