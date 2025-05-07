// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol KeychainRepositoryProtocol: Sendable {
    func add(_ value: Data, to account: String) throws
    func find(in account: String) throws -> Data
    func delete(in account: String) throws
    func update(_ value: Data, in account: String) throws
    func resetKeychain() throws
}

public final class KeychainRepository: KeychainRepositoryProtocol {
    public typealias KeychainError = MEGAInfrastructure.KeychainError

    private let serviceName: String
    private let appGroup: String?

    public init(
        serviceName: String,
        appGroup: String? = nil
    ) {
        self.serviceName = serviceName
        self.appGroup = appGroup
    }

    public func add(_ value: Data, to account: String) throws {
        var query = query(account: account)
        query[kSecValueData] = value

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw mapStatusToError(status)
        }
    }

    public func find(in account: String) throws -> Data {
        var query = query(account: account)
        query[kSecReturnData] = kCFBooleanTrue

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return data
        } else {
            throw mapStatusToError(status)
        }
    }

    public func delete(in account: String) throws {
        let query = query(account: account)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapStatusToError(status)
        }
    }

    public func update(_ value: Data, in account: String) throws {
        let query = query(account: account)
        let updateFields = [kSecValueData: value] as CFDictionary

        let status = SecItemUpdate(query as CFDictionary, updateFields)
        guard status == errSecSuccess else {
            throw mapStatusToError(status)
        }
    }

    public func resetKeychain() throws {
        var dictionary: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName
        ]

        if let appGroup {
            dictionary[kSecAttrAccessGroup] = appGroup
        }

        let status = SecItemDelete(dictionary as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapStatusToError(status)
        }
    }

    func query(
        account: String
    ) -> [CFString: Any] {
        var query : [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: account
        ]
        if let appGroup {
            query[kSecAttrAccessGroup] = appGroup
        }
        return query
    }

    func mapStatusToError(_ status: OSStatus) -> KeychainError {
        switch status {
        case errSecItemNotFound:
            .notFound
        case errSecDuplicateItem:
            .duplicateItem
        case errSecAuthFailed:
            .authenticationFailed
        case errSecInteractionNotAllowed:
            .interactionNotAllowed
        case errSecParam:
            .invalidParameters
        case errSecMissingEntitlement:
            .missingEntitlement
        default:
            .generic
        }
    }
}
