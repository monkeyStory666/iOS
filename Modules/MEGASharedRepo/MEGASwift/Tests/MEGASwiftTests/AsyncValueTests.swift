import Foundation
import Testing
import MEGASwift

struct AsyncValueTests {
    @Test func withAsyncThrowingValue_withSuccessResult_returnsExpectedValue() async throws {
        let expectedValue: String = "Success"

        let value = try await withAsyncThrowingValue { (completion: @escaping (Result<String, any Error>) -> Void) in
            completion(.success(expectedValue))
        }

        #expect(value == expectedValue)
    }

    @Test func withAsyncThrowingValue_withFailureResult_throwsExpectedError() async {
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)

        await #expect(
            performing: {
                _ = try await withAsyncThrowingValue { (completion: @escaping (Result<String, any Error>) -> Void) in
                    completion(.failure(expectedError))
                }
            },
            throws: { error in
                (error as NSError).domain == expectedError.domain
            }
        )
    }

    @Test func withAsyncThrowingValue_withCancelledTask_throwsCancellationError() async {
        let task = Task {
            do {
                _ = try await withAsyncThrowingValue { (completion: @Sendable @escaping (Result<String, any Error>) -> Void) in
                    // Simulate some delay before completion
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        completion(.success("Success"))
                    }
                }
                Issue.record("Expected CancellationError to be thrown")
            } catch is CancellationError {
                // Expected outcome
            } catch {
                Issue.record("Unexpected error thrown: \(error)")
            }
        }

        task.cancel()
        await task.value
    }

    @Test func withAsyncValue_withSuccessResult_returnsExpectedValue() async {
        let expectedValue: String = "Success"

        let value = await withAsyncValue { (completion: @escaping (Result<String, Never>) -> Void) in
            completion(.success(expectedValue))
        }

        #expect(value == expectedValue)
    }
}

