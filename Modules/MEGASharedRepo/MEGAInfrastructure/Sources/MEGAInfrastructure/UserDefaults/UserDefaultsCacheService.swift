// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGALogger

public protocol CacheServiceProtocol: Sendable {
    func save<T: Encodable>(_ object: T, for key: String) throws
    func fetch<T: Decodable>(for key: String) throws -> T?
    func removePersistentDomain(forName domainName: String)
}

public struct UserDefaultsCacheService: CacheServiceProtocol {
    nonisolated(unsafe) private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save<T: Encodable>(_ object: T, for key: String) throws {
        do {
            let encodedObject = try JSONEncoder().encode(object)
            userDefaults.set(encodedObject, forKey: key)
            MEGALogInfo("Saved object for key (\(key)): \(String(describing: object))")
        } catch {
            MEGALogError("Failed to save object for key (\(key)): \(error)")
            throw error
        }
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        do {
            let result: T? = try {
                guard let savedObject = userDefaults.object(forKey: key) as? Data else {
                    return nil
                }

                return try JSONDecoder().decode(T.self, from: savedObject)
            }()
            MEGALogInfo("Fetched object for key (\(key)): \(String(describing: result))")
            return result
        } catch {
            MEGALogError("Failed to fetch object for key (\(key)): \(error)")
            throw error
        }
    }

    public func removePersistentDomain(forName domainName: String) {
        userDefaults.removePersistentDomain(forName: domainName)
    }
}
