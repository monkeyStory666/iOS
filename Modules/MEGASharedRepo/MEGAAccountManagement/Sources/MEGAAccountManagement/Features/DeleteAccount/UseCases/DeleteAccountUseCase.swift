// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation

public protocol DeleteAccountUseCaseProtocol {
    func myEmail() -> String?
    func deleteAccount(with pin: String?) async throws
    func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform
    func pollForLogout(logoutHandler: (() -> Void)?) -> Cancellable
}

public extension DeleteAccountUseCaseProtocol {
    func pollForLogout() -> Cancellable {
        pollForLogout(logoutHandler: nil)
    }
}

public final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol {
    private var logoutPollingCancellable: Cancellable?

    private(set) var logoutPollTask: Task<Void, Never>?

    private let repository: any DeleteAccountRepositoryProtocol
    private let logoutPollingPublisher: AnyPublisher<Date, Never> // Injected timer publisher

    init(
        repository: any DeleteAccountRepositoryProtocol,
        logoutPollingPublisher: AnyPublisher<Date, Never>
    ) {
        self.repository = repository
        self.logoutPollingPublisher = logoutPollingPublisher
    }

    public func myEmail() -> String? {
        repository.myEmail()
    }

    public func deleteAccount(with pin: String?) async throws {
        try await repository.deleteAccount(with: pin)
    }

    public func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform {
        try await repository.fetchSubscriptionPlatform()
    }

    public func pollForLogout(logoutHandler: (() -> Void)?) -> Cancellable {
        if let logoutPollingCancellable { return logoutPollingCancellable }

        let cancellable = logoutPollingPublisher
            .sink { [weak self] _ in
                self?.logoutPollTask?.cancel()
                self?.logoutPollTask = Task(priority: .background) { [weak self] in
                    guard let self, !Task.isCancelled else { return }

                    let hasLoggedOut = await self.repository.hasLoggedOut()

                    guard !Task.isCancelled else { return }

                    if hasLoggedOut {
                        logoutPollingCancellable?.cancel()
                        logoutPollingCancellable = nil
                        logoutHandler?()
                    }
                }
            }
        logoutPollingCancellable = cancellable
        return cancellable
    }
}
