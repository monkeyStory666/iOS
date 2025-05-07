// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public struct LoginStoreRepository: LoginStoreRepositoryProtocol {
    private let keychainRepository: any KeychainRepositoryProtocol
    private let keychainAccount: String

    public init(
        keychainRepository: some KeychainRepositoryProtocol,
        keychainAccount: String
    ) {
        self.keychainRepository = keychainRepository
        self.keychainAccount = keychainAccount
    }

    public func set(session: String, updateDuplicateSession: Bool) throws {
        let sessionData = session.data(using: .utf8) ?? Data()
        do {
            try keychainRepository.add(sessionData, to: keychainAccount)
        } catch KeychainRepository.KeychainError.generic {
            try keychainRepository.update(sessionData, in: keychainAccount)
        } catch KeychainRepository.KeychainError.duplicateItem {
            if updateDuplicateSession {
                try keychainRepository.update(sessionData, in: keychainAccount)
            } else {
                throw KeychainRepository.KeychainError.duplicateItem
            }
        }
    }

    public func session() throws -> String {
        let sessionData = try keychainRepository.find(in: keychainAccount)
        guard let session = String(data: sessionData, encoding: .utf8) else {
            throw LoginErrorEntity.generic
        }
        return session
    }

    public func delete() throws {
        try keychainRepository.delete(in: keychainAccount)
    }
}
