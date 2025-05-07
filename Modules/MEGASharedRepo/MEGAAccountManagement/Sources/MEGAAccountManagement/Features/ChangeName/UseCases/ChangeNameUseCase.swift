// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol ChangeNameUseCaseProtocol {
    func changeName(
        firstName: String,
        lastName: String
    ) async throws
}

public struct ChangeNameUseCase: ChangeNameUseCaseProtocol {
    private let accountNameRepository: any AccountNameRepositoryProtocol

    public init(accountNameRepository: some AccountNameRepositoryProtocol) {
        self.accountNameRepository = accountNameRepository
    }

    public func changeName(
        firstName: String,
        lastName: String
    ) async throws {
        try await accountNameRepository.changeName(
            firstName: firstName,
            lastName: lastName
        )
    }
}
