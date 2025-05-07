@testable import MEGAStoreKit
import XCTest

final class StoreErrorTests: XCTestCase {
    func testErrorDescription_shouldNotBeNil() {
        func assert(
            whenError error: StoreError,
            line: UInt = #line
        ) {
            XCTAssertNotNil(error.errorDescription, line: line)
        }

        assert(whenError: .system("systemError"))
        assert(whenError: .notAvailableInRegion)
        assert(whenError: .invalid("invalidError"))
        assert(whenError: .generic("genericError"))
        assert(whenError: .offerInvalid("offerInvalidError"))
        assert(whenError: .networkError)
    }

    func testFailureReason_shouldNotBeNil() {
        func assert(
            whenError error: StoreError,
            line: UInt = #line
        ) {
            XCTAssertNotNil(error.failureReason, line: line)
        }

        assert(whenError: .system("systemError"))
        assert(whenError: .notAvailableInRegion)
        assert(whenError: .invalid("invalidError"))
        assert(whenError: .generic("genericError"))
        assert(whenError: .offerInvalid("offerInvalidError"))
        assert(whenError: .networkError)
    }

    func testStoreError_shouldBeCodable() {
        func assert(
            whenError error: StoreError,
            line: UInt = #line
        ) {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            do {
                let data = try encoder.encode(error)
                let decodedError = try decoder.decode(StoreError.self, from: data)
                XCTAssertEqual(error, decodedError, line: line)
            } catch {
                XCTFail("Failed to encode or decode StoreError: \(error)", line: line)
            }
        }

        assert(whenError: .system("systemError"))
        assert(whenError: .notAvailableInRegion)
        assert(whenError: .invalid("invalidError"))
        assert(whenError: .generic("genericError"))
        assert(whenError: .offerInvalid("offerInvalidError"))
        assert(whenError: .networkError)
    }

    func testStoreError_shouldBeHashable() {
        func assert(
            whenError error: StoreError,
            line: UInt = #line
        ) {
            let errors: Set<StoreError> = [
                .system("systemError"),
                .notAvailableInRegion,
                .invalid("invalidError"),
                .generic("genericError"),
                .offerInvalid("offerInvalidError"),
                .networkError
            ]

            XCTAssertTrue(errors.contains(error), line: line)
        }

        assert(whenError: .system("systemError"))
        assert(whenError: .notAvailableInRegion)
        assert(whenError: .invalid("invalidError"))
        assert(whenError: .generic("genericError"))
        assert(whenError: .offerInvalid("offerInvalidError"))
        assert(whenError: .networkError)
    }
}
