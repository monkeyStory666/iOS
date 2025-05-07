// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

public final class MockKeychainRepository: MockObject<MockKeychainRepository.Actions>,
    KeychainRepositoryProtocol
{
    public enum Actions {
        case add, find, delete, update, resetKeychain
    }

    static var newRepo: MockKeychainRepository { .init() }

    public var _addError: Error?
    public var _find: Data?
    public var _deleteError: Error?
    public var _updateError: Error?

    public func resetKeychain() throws {
        actions.append(.resetKeychain)
    }

    public func add(_ value: Data, to account: String) throws {
        actions.append(.add)
        if let _addError {
            throw _addError
        }
    }

    public func find(in account: String) throws -> Data {
        actions.append(.find)
        if let _find {
            return _find
        }
        throw KeychainRepository.KeychainError.generic
    }

    public func delete(in account: String) throws {
        actions.append(.delete)
        if let _deleteError {
            throw _deleteError
        }
    }

    public func update(_ value: Data, in account: String) throws {
        actions.append(.update)
        if let _updateError {
            throw _updateError
        }
    }
}
