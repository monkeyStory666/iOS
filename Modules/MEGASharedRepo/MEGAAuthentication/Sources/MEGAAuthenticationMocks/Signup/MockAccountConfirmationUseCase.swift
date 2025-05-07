// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockAccountConfirmationUseCase:
    MockObject<MockAccountConfirmationUseCase.Action>,
    AccountConfirmationUseCaseProtocol {
    public enum Action: Equatable {
        case resendSignUpLink(email: String, name: String)
        case cancelCreateAccount
        case waitForAccountConfirmationEvent
        case verifyAccount(confirmationLinkUrl: String)
    }

    private let resendSignUpLinkResult: Result<Void, any Error>
    private let verifyAccountResult: Result<Bool, any Error>

    public init(
        resendSignUpLinkResult: Result<Void, any Error> = .success(()),
        verifyAccountResult: Result<Bool, any Error> = .success(true)
    ) {
        self.resendSignUpLinkResult = resendSignUpLinkResult
        self.verifyAccountResult = verifyAccountResult
        super.init()
    }

    public func resendSignUpLink(withEmail email: String, name: String) async throws {
        actions.append(.resendSignUpLink(email: email, name: name))
        try resendSignUpLinkResult.get()
    }

    public func cancelCreateAccount() {
        actions.append(.cancelCreateAccount)
    }

    public func waitForAccountConfirmationEvent() async {
        actions.append(.waitForAccountConfirmationEvent)
    }

    public func verifyAccount(
        with confirmationLinkUrl: String
    ) async throws -> Bool {
        actions.append(.verifyAccount(confirmationLinkUrl: confirmationLinkUrl))
        return try verifyAccountResult.get()
    }
}
