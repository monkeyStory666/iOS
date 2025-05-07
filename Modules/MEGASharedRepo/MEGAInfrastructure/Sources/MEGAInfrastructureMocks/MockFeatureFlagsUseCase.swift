// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

public final class MockFeatureFlagsUseCase: MockObject<MockFeatureFlagsUseCase.Action>, FeatureFlagsUseCaseProtocol {
    public enum Action: Equatable {
        case save(SaveParam)
        case fetch(String)
    }

    public var _save: Error?
    public var _fetch: Decodable?

    public init(
        save: Error? = nil,
        fetch: Decodable? = nil
    ) {
        _save = save
        _fetch = fetch
    }

    public func set<T: Encodable>(_ value: T, for key: String) {
        actions.append(.save(.init(object: value, key: key)))
    }

    public func get<T: Decodable>(for key: String) -> T? {
        actions.append(.fetch(key))
        return (_fetch as? T)
    }
}

public extension MockFeatureFlagsUseCase {
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
