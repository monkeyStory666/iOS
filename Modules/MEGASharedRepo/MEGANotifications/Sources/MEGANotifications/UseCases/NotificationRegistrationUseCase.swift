// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public protocol NotificationRegistrationUseCaseProtocol {
    func register(deviceToken: String)
}

public struct NotificationRegistrationUseCase: NotificationRegistrationUseCaseProtocol {
    private let repo: any NotificationRegistrationRepositoryProtocol

    public init(repo: some NotificationRegistrationRepositoryProtocol) {
        self.repo = repo
    }

    public func register(deviceToken: String) {
        repo.register(deviceToken: deviceToken)
    }
}
