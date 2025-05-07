// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest

public final class MockAccountConfirmationRepository:
    MockObject<MockAccountConfirmationRepository.Action>,
    AccountConfirmationRepositoryProtocol,
    @unchecked Sendable {
    public enum Action: Equatable {
        case resendSignUpLink(email: String, name: String)
        case cancelCreateAccount
        case waitForAccountConfirmationEvent
        case querySignupLink(confirmationLinkUrl: String)
        case verifyAccount(confirmationLinkUrl: String, password: String)
    }

    private let resendSignUpLinkResult: Result<Void, any Error>
    private let querySignupLinkResult: Result<Bool, any Error>
    private let verifyAccountResult: Result<Bool, any Error>

    public init(
        resendSignUpLinkResult: Result<Void, any Error> = .success(()),
        querySignupLinkResult: Result<Bool, any Error> = .success(true),
        verifyAccountResult: Result<Bool, any Error> = .success(true)
    ) {
        self.resendSignUpLinkResult = resendSignUpLinkResult
        self.querySignupLinkResult = querySignupLinkResult
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

    public func querySignupLink(
        with confirmationLinkUrl: String
    ) async throws -> Bool {
        actions.append(.querySignupLink(confirmationLinkUrl: confirmationLinkUrl))
        return try querySignupLinkResult.get()
    }

    public func verifyAccount(
        with confirmationLinkUrl: String,
        password: String
    ) async throws -> Bool {
        actions.append(.verifyAccount(confirmationLinkUrl: confirmationLinkUrl, password: password))
        return try verifyAccountResult.get()
    }
}
