/**
 Wraps an asynchronous operation that may throw into an async/await call.

 This function bridges a callback-based asynchronous API into Swift's async/await world.
 It uses `withCheckedThrowingContinuation` to suspend the current task until the operation completes,
 and ensures that the task cancellation is respected.

 - Parameter operation: A callback-based asynchronous operation that takes a `@Sendable` closure
   which returns a `Result<T, any Error>`.
 - Returns: The value of type `T` produced by the asynchronous operation.
 - Throws: An error if the operation fails or if the task is cancelled.
 */
public func withAsyncThrowingValue<T: Sendable>(
    in operation: (@Sendable @escaping (Result<T, any Error>) -> Void) -> Void
) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        // Check if the task has been cancelled before starting the operation.
        guard Task.isCancelled == false else {
            continuation.resume(throwing: CancellationError())
            return
        }

        // Call the provided operation and resume the continuation when a result is returned.
        operation { result in
            // Check again for cancellation before resuming the continuation.
            guard Task.isCancelled == false else {
                continuation.resume(throwing: CancellationError())
                return
            }
            continuation.resume(with: result)
        }
    }
}

/**
 Wraps an asynchronous operation that does not throw into an async/await call.

 This function bridges a callback-based asynchronous API (that never fails) into Swift's async/await world.
 It uses `withCheckedContinuation` to suspend the current task until the operation completes.

 - Parameter operation: A callback-based asynchronous operation that takes a `@Sendable` closure
   which returns a `Result<T, Never>`.
 - Returns: The value of type `T` produced by the asynchronous operation.
 */
public func withAsyncValue<T: Sendable>(
    in operation: (@Sendable @escaping (Result<T, Never>) -> Void) -> Void
) async -> T {
    await withCheckedContinuation { continuation in
        operation { result in
            continuation.resume(with: result)
        }
    }
}
