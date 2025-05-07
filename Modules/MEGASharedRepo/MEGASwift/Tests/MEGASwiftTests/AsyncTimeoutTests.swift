// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import Testing
import MEGASwift

struct AsyncTimeoutTests {
    @Test func withAsyncThrowingValue_successfulCompletion() async throws {
        let timeout: TimeInterval = 1.0
        let expectedResult = 42

        let result = try await withAsyncThrowingValue(timeout: timeout) { completion in
            // Simulate a asynchronous operation
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.success(expectedResult))
            }
        }

        #expect(result == expectedResult)
    }

    @Test func withAsyncThrowingValue_timeoutError() async throws {
        let timeout: TimeInterval = 1.0

        await #expect(
            performing: {
                _ = try await withAsyncThrowingValue(timeout: timeout) { completion in
                    // Simulate a long-running operation
                    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                        completion(.success(42)) // This should never be reached
                    }
                }
            },
            throws: { error in
                error is TimedOutError
            }
        )
    }

    @Test func withAsyncValue_successfulCompletion() async throws {
        let timeout: TimeInterval = 1.0
        let expectedResult = 42

        let result = try await withAsyncValue(timeout: timeout) { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.success(expectedResult))
            }
        }

        #expect(result == expectedResult)
    }

    @Test func withAsyncValue_timeoutError() async throws {
        let timeout: TimeInterval = 1.0

        await #expect(
            performing: {
                _ = try await withAsyncValue(timeout: timeout) { completion in
                    // Simulate a long-running operation
                    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                        completion(.success(42)) // This should never be reached
                    }
                }
            },
            throws: { error in
                error is TimedOutError
            }
        )
    }
}


