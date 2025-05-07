// Copyright © 2023 MEGA Limited. All rights reserved.

public extension Sequence where Element: Sendable {
    /// Performs an async map operation on a sequence.
    ///
    /// - Parameter transform: The asynchronous transformation closure that accepts an element and
    /// returns a transformed value.
    /// - Returns: An array of transformed values.
    /// - Throws: Any errors thrown inside the `transform` closure.
    ///
    /// **Example Usage**
    /// ```
    /// let ids = [1, 2, 3]
    /// let users = try await ids.asyncMap { id in
    ///     return await fetchUser(by: id)
    /// }
    /// print(users)  // Output: [User(id: 1, ...), User(id: 2, ...), User(id: 3, ...)]
    /// ```
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    /// Performs an async forEach operation on a sequence.
    ///
    /// - Parameter operation: The asynchronous operation closure that accepts an element.
    /// - Throws: Any errors thrown inside the `operation` closure.
    ///
    /// **Example Usage**
    /// ```
    /// let ids = [1, 2, 3]
    /// await ids.asyncForEach { id in
    ///     let user = await fetchUser(by: id)
    ///     print(user)
    /// }
    /// // Output: User(id: 1, ...)
    /// //         User(id: 2, ...)
    /// //         User(id: 3, ...)
    /// ```
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    /// Performs a concurrent forEach operation on a sequence.
    ///
    /// - Parameter operation: The asynchronous operation closure that accepts an element.
    ///
    /// **Example Usage**
    /// ```
    /// let ids = [1, 2, 3]
    /// await ids.concurrentForEach { id in
    ///     let user = await fetchUser(by: id)
    ///     print(user)
    /// }
    /// // Output: The order may vary due to concurrency.
    /// ```
    func concurrentForEach(
        _ operation: @Sendable @escaping (Element) async -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }

    /// Performs a concurrent map operation on a sequence.
    ///
    /// - Parameter transform: The asynchronous transformation closure that accepts an element and
    /// returns a transformed value.
    /// - Returns: An array of transformed values.
    /// - Throws: Any errors thrown inside the `transform` closure.
    ///
    /// **Example Usage**
    /// ```
    /// let ids = [1, 2, 3]
    /// let users = try await ids.concurrentMap { id in
    ///     return try await fetchUser(by: id)
    /// }
    /// print(users)  // Output: The order will be [User(id: 1, ...), User(id: 2, ...), User(id: 3,
    /// ...)]
    /// ```
    func concurrentMap<T:Sendable>(
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            // TODO: Unhandled Throwing Task - Look for workaround
            // swiftlint:disable:next unhandled_throwing_task
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }

    /// Performs a concurrent map operation on a sequence for non-throwing functions.
    ///
    /// - Parameter transform: The asynchronous transformation closure that accepts an element and
    /// returns a transformed value.
    /// - Returns: An array of transformed values.
    ///
    /// **Example Usage**
    /// ```
    /// let ids = [1, 2, 3]
    /// let users = await ids.concurrentMap { id in
    ///     return await fetchUser(by: id)
    /// }
    /// print(users)  // Output: The order will be [User(id: 1, ...), User(id: 2, ...), User(id: 3,
    /// ...)]
    /// ```
    func concurrentMap<T:Sendable>(
        _ transform: @Sendable @escaping (Element) async -> T
    ) async -> [T] {
        let tasks = map { element in
            Task {
                await transform(element)
            }
        }

        return await tasks.asyncMap { task in
            await task.value
        }
    }
}
