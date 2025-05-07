// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import Testing

@discardableResult
public func confirmation<P: Publisher>(
    in publisher: P,
    _ comment: Comment? = nil,
    expectedCount: Int = 1,
    timeout: TimeInterval = 5,
    completeOnExpectedCount: Bool = true,
    when body: @escaping () async throws -> Void
) async rethrows -> [P.Output] {
    return try await confirmation(comment, expectedCount: expectedCount) { confirmation in
        var values: [P.Output] = []
        var cancellable: AnyCancellable?

        do {
            return try await withAsyncThrowingValue(timeout: timeout) { continuation in
                let complete = {
                    cancellable?.cancel()
                    continuation(.success(values))
                }

                cancellable = publisher.sink(
                    receiveCompletion: { _ in
                        complete()
                    },
                    receiveValue: {
                        confirmation()
                        values.append($0)
                        if values.count == expectedCount, completeOnExpectedCount {
                            complete()
                        }
                    }
                )

                Task {
                    do {
                        try await body()
                    } catch {
                        cancellable?.cancel()
                        continuation(.failure(error))
                    }
                }
            }
        } catch {
            if error as? ConfirmationError != .timedOut {
                throw error
            } else {
                return values
            }
        }
    }
}

// MARK: - Helpers

public enum ConfirmationError: Error {
    case timedOut
}

private func withAsyncThrowingValue<T>(
    in operation: (@escaping (Result<T, any Error>) -> Void)
        -> Void
) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
        guard Task.isCancelled == false else {
            continuation.resume(throwing: CancellationError())
            return
        }

        operation { result in
            guard Task.isCancelled == false else {
                continuation.resume(throwing: CancellationError())
                return
            }

            continuation.resume(with: result)
        }
    }
}

private func withAsyncThrowingValue<T>(
    timeout: TimeInterval,
    in operation: @escaping (@escaping (Result<T, any Error>) -> Void) -> Void
) async throws -> T {
    try await withTimeout(seconds: timeout) {
        try await withAsyncThrowingValue(in: operation)
    }
}

private func withTimeout<Return: Sendable>(
    seconds: TimeInterval,
    @_inheritActorContext _ operation: @escaping @Sendable () async throws -> Return
) async throws -> Return {
    try await withTimeout(nanoseconds: UInt64(seconds) * NSEC_PER_SEC) {
        try await operation()
    }
}

private func withTimeout<Return: Sendable>(
    nanoseconds: UInt64,
    @_inheritActorContext isolation: isolated (any Actor)? = #isolation,
    _ operation: @escaping @Sendable () async throws -> Return
) async throws -> Return {
    let task = Ref<Task<Void, Never>>(value: nil)
    let timeoutTask = Ref<Task<Void, any Error>>(value: nil)

    let flag = Flag()

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
            Return,
            Error
        >) in
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
                    continuation.resume(throwing: ConfirmationError.timedOut)
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

private final class Ref<T>: @unchecked Sendable {
    var value: T?

    init(value: T?) {
        self.value = value
    }
}

private actor Flag {
    var value = false

    func set(value: Bool) {
        self.value = value
    }

    func performIf(expected: Bool, perform: @Sendable () -> Bool) {
        if value == expected {
            value = perform()
        }
    }
}
