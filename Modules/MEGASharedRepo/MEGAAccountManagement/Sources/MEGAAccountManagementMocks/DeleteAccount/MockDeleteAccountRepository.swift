// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGATest

public final class MockDeleteAccountRepository:
    MockObject<MockDeleteAccountRepository.Action>,
    DeleteAccountRepositoryProtocol {
    public enum Action: Equatable {
        case myEmail
        case deleteAccount(pin: String?)
        case fetchSubscriptionPlatform
        case hasLoggedOut
    }

    public var _myEmail: String?
    public var _fetchSubscriptionPlatform: Result<SubscriptionPlatform, Error>
    public var _deleteAccountResult: Result<Void, DeleteAccountRepository.Error>
    public var _hasLoggedOut: Bool

    public init(
        myEmail: String? = nil,
        subscriptionPlatform: Result<SubscriptionPlatform, Error> = .success(.other),
        deleteAccountResult: Result<Void, DeleteAccountRepository.Error> = .success(()),
        hasLoggedOut: Bool = false
    ) {
        self._myEmail = myEmail
        self._fetchSubscriptionPlatform = subscriptionPlatform
        self._deleteAccountResult = deleteAccountResult
        self._hasLoggedOut = hasLoggedOut
        super.init()
    }

    public func myEmail() -> String? {
        actions.append(.myEmail)
        return _myEmail
    }

    public func deleteAccount(with pin: String?) async throws {
        actions.append(.deleteAccount(pin: pin))
        try _deleteAccountResult.get()
    }

    public func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform {
        actions.append(.fetchSubscriptionPlatform)
        return try _fetchSubscriptionPlatform.get()
    }

    public func hasLoggedOut() async -> Bool {
        actions.append(.hasLoggedOut)
        return _hasLoggedOut
    }
}

