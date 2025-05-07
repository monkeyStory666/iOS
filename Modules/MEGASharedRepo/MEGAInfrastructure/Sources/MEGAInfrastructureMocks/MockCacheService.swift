// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

public final class MockCacheService: MockObject<MockCacheService.Action>, CacheServiceProtocol {
    public enum Action: Equatable {
        case save(SaveParam)
        case fetch(String)
        case removePersistentDomain(domainName: String)
    }

    public var _save: Error?
    public var _fetch: (String) -> Result<Decodable?, Error>

    public init(save: Error? = nil, fetch: Result<Decodable?, Error> = .success(nil)) {
        _save = save
        _fetch = { _ in fetch }
    }

    public init(
        save: Error? = nil,
        fetch: @escaping (String) -> Result<Decodable?, Error>
    ) {
        _save = save
        _fetch = fetch
    }

    public func save<T: Encodable>(_ object: T, for key: String) throws {
        if let error = _save {
            throw error
        } else {
            actions.append(.save(.init(object: object, key: key)))
        }
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        actions.append(.fetch(key))
        switch _fetch(key) {
        case .success(let decodableData):
            return decodableData as? T
        case .failure(let error):
            throw error
        }
    }

    public func removePersistentDomain(forName domainName: String) {
        actions.append(.removePersistentDomain(domainName: domainName))
    }
}

public extension MockCacheService {
    struct SaveParam: Equatable {
        public let object: Encodable
        public let key: String

        public init(object: Encodable, key: String) {
            self.object = object
            self.key = key
        }

        public static func == (lhs: SaveParam, rhs: SaveParam) -> Bool {
            guard let lhsData = try? JSONEncoder().encode(lhs.object),
                  let rhsData = try? JSONEncoder().encode(rhs.object) else {
                return false
            }

            return lhs.key == rhs.key && lhsData == rhsData
        }
    }
}
