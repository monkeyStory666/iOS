// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import Testing

@Suite(.serialized)
final class UserDefaultCacheServiceTests {
    private let testUserDefaults: UserDefaults!
    private let suiteName: String

    init() {
        suiteName = .random(withPrefix: "unittest")
        testUserDefaults = UserDefaults(suiteName: suiteName)
    }

    deinit {
        // Remove all data in the test suite
        testUserDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test func save_andFetch_shouldStoreAndRetrieveObject() throws {
        let sut = makeSUT()
        let key = "testKey"
        let objectToSave = TestObject(id: 1, name: "Test")

        try sut.save(objectToSave, for: key)
        let retrievedObject: TestObject? = try sut.fetch(for: key)

        #expect(
            retrievedObject == objectToSave,
            "Saved and retrieved object should be equal"
        )
    }

    @Test func fetch_shouldReturnNilIfKeyDoesNotExist() throws {
        let sut = makeSUT()
        let key = "nonExistentKey"

        let retrievedObject: TestObject? = try sut.fetch(for: key)

        #expect(
            retrievedObject == nil,
            "Fetching a non-existent key should return nil"
        )
    }

    @Test func save_shouldOverrideExistingObject() throws {
        let sut = makeSUT()
        let key = "testKey"
        let firstObject = TestObject(id: 1, name: "First")
        let secondObject = TestObject(id: 2, name: "Second")

        try sut.save(firstObject, for: key)
        try sut.save(secondObject, for: key)
        let retrievedObject: TestObject? = try sut.fetch(for: key)

        #expect(
            retrievedObject == secondObject,
            "Saving an object with an existing key should override the old object"
        )
    }

    @Test func removePersistentDomain_shouldClearAllDataInDomain() {
        let sut = makeSUT()

        testUserDefaults.set("testValue", forKey: "testKey")
        sut.removePersistentDomain(forName: suiteName)

        #expect(
            testUserDefaults.value(forKey: "testKey") == nil,
            "Persistent domain should be cleared after calling removePersistentDomain"
        )
    }

    // MARK: - Test Helpers

    private func makeSUT() -> UserDefaultsCacheService {
        UserDefaultsCacheService(userDefaults: testUserDefaults)
    }

    private struct TestObject: Codable, Equatable {
        let id: Int
        let name: String
    }
}
