// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockFeatureFlagsRepository:
    MockObject<MockFeatureFlagsRepository.Action>,
    FeatureFlagsRepositoryProtocol {
    public enum Action {
        case setValue(Encodable, forKey: String)
        case getValue(forKey: String)
    }

    private var storage: [String: Any] = [:]

    public init(storage: [String: Any] = [:]) {
        self.storage = storage
    }

    public func set<T: Encodable>(_ value: T, for key: String) {
        actions.append(.setValue(value, forKey: key))
        storage[key] = value
    }

    public func get<T: Decodable>(for key: String) -> T? {
        actions.append(.getValue(forKey: key))
        return storage[key] as? T
    }
}

extension MockFeatureFlagsRepository.Action: Equatable {
    public static func == (
        lhs: MockFeatureFlagsRepository.Action,
        rhs: MockFeatureFlagsRepository.Action
    ) -> Bool {
        switch (lhs, rhs) {
        case let (.setValue(value1, key1), .setValue(value2, key2)):
            return key1 == key2 && "\(value1)" == "\(value2)"
        case let (.getValue(key1), .getValue(key2)):
            return key1 == key2
        default:
            return false
        }
    }
}
