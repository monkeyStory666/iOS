import Foundation

/**
 Executes an asynchronous throwing operation with an optional timeout.
 
 This function wraps an asynchronous operation that returns its result via a callback
 into an async throwing function. If a timeout is provided and the operation does not complete
 within that interval, a `TimedOutError` is thrown.
 
 - Parameters:
 - timeout: An optional timeout interval in seconds. If provided, the operation must complete within this time.
 - operation: A closure that takes a callback closure. The callback is used to return the result of the asynchronous operation.
 Both the operation and its callback are marked with `@Sendable` for concurrency safety.
 - Returns: The value produced by the asynchronous operation.
 - Throws: An error if the operation fails or if the timeout is reached.
 */
public func withAsyncThrowingValue<T: Sendable>(
    timeout: TimeInterval?,
    in operation: @Sendable @escaping (@Sendable @escaping (Result<T, any Error>) -> Void) -> Void
) async throws -> T {
    if let timeout {
        return try await withTimeout(nanoseconds: UInt64(timeout) * NSEC_PER_SEC) {
            try await withAsyncThrowingValue(in: operation)
        }
    } else {
        return try await withAsyncThrowingValue(in: operation)
    }
}

/**
 Executes an asynchronous operation that does not throw with an optional timeout.
 
 This function wraps an asynchronous operation that returns its result via a callback
 into an async function. If a timeout is provided and the operation does not complete
 within that interval, a `TimedOutError` is thrown.
 
 - Parameters:
 - timeout: An optional timeout interval in seconds. If provided, the operation must complete within this time.
 - operation: A closure that takes a callback closure. The callback returns the result of the asynchronous operation.
 Both the operation and its callback are marked with `@Sendable` for concurrency safety.
 - Returns: The value produced by the asynchronous operation.
 - Throws: An error if the operation fails or if the timeout is reached.
 */
public func withAsyncValue<T: Sendable>(
    timeout: TimeInterval?,
    in operation: @Sendable @escaping (@Sendable @escaping (Result<T, Never>) -> Void) -> Void
) async throws -> T {
    if let timeout {
        return try await withTimeout(nanoseconds: UInt64(timeout) * NSEC_PER_SEC) {
            await withAsyncValue(in: operation)
        }
    } else {
        return await withAsyncValue(in: operation)
    }
}

// MARK: - Swift Async Timeout

/**
 Executes an asynchronous throwing operation with a timeout specified in seconds.
 
 This convenience function converts the timeout from seconds to nanoseconds and then invokes the underlying
 `withTimeout(nanoseconds:isolation:_:)` function.
 
 - Parameters:
 - seconds: The timeout interval in seconds.
 - operation: A closure representing the asynchronous throwing operation. It inherits the current actor context.
 - Returns: The result of the asynchronous operation.
 - Throws: An error if the operation fails or if the timeout is reached.
 */
public func withTimeout<Return: Sendable>(
    seconds: TimeInterval,
    @_inheritActorContext _ operation: @escaping @Sendable () async throws -> Return
) async throws -> Return {
    try await withTimeout(nanoseconds: UInt64(seconds) * NSEC_PER_SEC) {
        try await operation()
    }
}

/**
 Executes an asynchronous throwing operation with a specified timeout in nanoseconds.
 
 This function creates two tasks—one for the operation and one for the timeout—and uses a flag actor to ensure
 that the continuation is resumed only once, either when the operation completes or when the timeout occurs.
 If the timeout elapses before the operation completes, the operation task is cancelled and a `TimedOutError` is thrown.
 
 - Parameters:
 - nanoseconds: The timeout interval in nanoseconds.
 - isolation: An optional actor for isolation. Defaults to the current actor's isolation.
 - operation: A closure representing the asynchronous throwing operation. It is marked with `@Sendable`.
 - Returns: The result of the asynchronous operation.
 - Throws: An error if the operation fails or if the timeout is reached.
 */
public func withTimeout<Return: Sendable>(
    nanoseconds: UInt64,
    @_inheritActorContext isolation: isolated (any Actor)? = #isolation,
    _ operation: @escaping @Sendable () async throws -> Return
) async throws -> Return {
    let task = Ref<Task<Void, Never>>(value: nil)
    let timeoutTask = Ref<Task<Void, any Error>>(value: nil)
    
    let flag = Flag()
    
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Return, any Error>) in
            do {
                try Task.checkCancellation()
            } catch {
                continuation.resume(throwing: error)
                return
            }
            
            let _task = Task {
                do {
                    let taskResult = try await operation()
                    await flag.performIf(expected: false) {
                        continuation.resume(returning: taskResult)
                        return true
                    }
                } catch {
                    await flag.performIf(expected: false) {
                        continuation.resume(throwing: error)
                        return true
                    }
                }
            }
            
            task.value = _task
            
            let _timeoutTask = Task {
                try await Task.sleep(nanoseconds: nanoseconds)
                _task.cancel()
                await flag.performIf(expected: false) {
                    continuation.resume(throwing: TimedOutError())
                    return true
                }
            }
            
            timeoutTask.value = _timeoutTask
        }
    } onCancel: {
        task.value?.cancel()
        timeoutTask.value?.cancel()
    }
}

/**
 A simple reference wrapper that holds a mutable value.
 
 This class is used internally to hold references to tasks within the timeout functions.
 It is marked as `@unchecked Sendable` because its thread safety is manually ensured by its usage context.
 
 - Note: This class is private to the module.
 */
private final class Ref<T>: @unchecked Sendable {
    var value: T?
    
    init(value: T?) {
        self.value = value
    }
}

/**
 An actor used to coordinate the resumption of a continuation.
 
 The `Flag` actor maintains a Boolean flag indicating whether the continuation has already been resumed.
 Its `performIf(expected:perform:)` method executes a closure if the flag's value matches the expected value,
 and then updates the flag accordingly to ensure that the continuation is resumed only once.
 */
private actor Flag {
    var value = false
    
    /// Sets the flag to the specified value.
    ///
    /// - Parameter value: The new value for the flag.
    func set(value: Bool) {
        self.value = value
    }
    
    /// Executes the provided closure if the flag matches the expected value.
    ///
    /// - Parameters:
    ///   - expected: The expected current value of the flag.
    ///   - perform: A closure that is executed if the flag matches the expected value. The closure should return a Boolean
    ///              value which is then assigned to the flag.
    func performIf(expected: Bool, perform: @Sendable () -> Bool) {
        if value == expected {
            value = perform()
        }
    }
}
