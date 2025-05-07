// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol RecoveryKeyUseCaseProtocol {
    func recoveryKey() -> String?
    func keyExported()
}

public struct RecoveryKeyUseCase: RecoveryKeyUseCaseProtocol {
    private let repository: any RecoveryKeyRepositoryProtocol

    public init(repository: some RecoveryKeyRepositoryProtocol) {
        self.repository = repository
    }

    public func recoveryKey() -> String? {
        repository.recoveryKey()
    }

    public func keyExported() {
        repository.keyExported()
    }
}
