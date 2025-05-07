// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGATest

public final class MockDeleteAccountUseCase: MockObject<MockDeleteAccountUseCase.Action>, DeleteAccountUseCaseProtocol {
    public enum Action: Equatable {
        case myEmail
        case deleteAccount(pin: String?)
        case fetchSubscriptionPlatform
        case pollForLogout
    }

    private let email: String?
    private let subscriptionPlatform: Result<SubscriptionPlatform, Error>
    private let deleteAccountResult: Result<Void, DeleteAccountRepository.Error>

    public init(
        email: String? = nil,
        subscriptionPlatform: Result<SubscriptionPlatform, Error> = .success(.other),
        deleteAccountResult: Result<Void, DeleteAccountRepository.Error> = .success(())
    ) {
        self.email = email
        self.subscriptionPlatform = subscriptionPlatform
        self.deleteAccountResult = deleteAccountResult
        super.init()
    }

    public func myEmail() -> String? {
        actions.append(.myEmail)
        return email
    }

    public func deleteAccount(with pin: String?) async throws {
        actions.append(.deleteAccount(pin: pin))
        try deleteAccountResult.get()
    }

    public func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform {
        actions.append(.fetchSubscriptionPlatform)
        return try subscriptionPlatform.get()
    }

    public func pollForLogout(logoutHandler: (() -> Void)?) -> Cancellable {
        actions.append(.pollForLogout)
        return AnyCancellable {}
    }
}
