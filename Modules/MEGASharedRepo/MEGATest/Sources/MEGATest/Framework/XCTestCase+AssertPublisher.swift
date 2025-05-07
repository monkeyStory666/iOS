// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import XCTest

public extension XCTestCase {
    /// Asserts a custom condition on the next emitted value from the publisher within a specified timeout, after performing an optional asynchronous throwing action.
    ///
    /// This method allows for executing an asynchronous action that may throw an error before asserting the publisher's output. The `handler` closure is used to perform custom assertions on the emitted value.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to observe.
    ///   - action: An optional asynchronous throwing action to perform before waiting for the publisher's output.
    ///   - handler: A closure that performs custom assertions on the emitted value.
    ///   - timeout: The maximum time to wait for the publisher to emit a value.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this method was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this method was called.
    ///
    /// Example Usage:
    /// ```
    /// let myPublisher = Just(5).eraseToAnyPublisher()
    /// await assertOnNextEmit(
    ///     from: myPublisher,
    ///     when: {
    ///         /* Perform async throwing action */
    ///     },
    ///     then: { nextValue in
    ///         XCTAssertEqual(nextValue, 5, "Expected next value to be 5")
    ///     },
    ///     timeout: 1.0
    /// )
    /// ```
    func assertOnNextEmit<T: Publisher>(
        from publisher: T,
        when action: () async throws -> Void = {},
        then handler: @escaping (T.Output) -> Void,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        let expectation = expectation(
            description: "Awaiting publisher next emit in file: \(file), line: \(line)"
        )

        let cancellable = publisher.sink(
            receiveCompletion: { _ in },
            receiveValue: { value in
                handler(value)
                expectation.fulfill()
            }
        )

        try await action()

        await fulfillment(of: [expectation], timeout: timeout)

        cancellable.cancel()
    }

    /// Asserts a custom condition on the next emitted value from the publisher within a specified timeout, after performing an optional asynchronous action.
    ///
    /// This method is similar to the async throws version but does not handle errors from the action. It is useful when the action is asynchronous but does not throw errors.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to observe.
    ///   - action: An optional asynchronous action to perform before waiting for the publisher's output.
    ///   - handler: A closure that performs custom assertions on the emitted value.
    ///   - timeout: The maximum time to wait for the publisher to emit a value.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this method was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this method was called.
    ///
    /// Example Usage:
    /// ```
    /// let myPublisher = Just(5).eraseToAnyPublisher()
    /// await assertOnNextEmit(
    ///     from: myPublisher,
    ///     when: {
    ///         /* Perform async action */
    ///     },
    ///     then: { nextValue in
    ///         XCTAssertEqual(nextValue, 5, "Expected next value to be 5")
    ///     },
    ///     timeout: 1.0
    /// )
    /// ```
    func assertOnNextEmit<T: Publisher>(
        from publisher: T,
        when action: () async -> Void = {},
        then handler: @escaping (T.Output) -> Void,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let action: () async throws -> Void = { await action() }

        try? await assertOnNextEmit(
            from: publisher,
            when: action,
            then: handler,
            timeout: timeout,
            file: file, line: line
        )
    }

    /// Asserts a custom condition on the next emitted value from the publisher within a specified timeout, after performing an optional throwing action.
    ///
    /// This method is for cases where a synchronous action that may throw errors is performed before asserting the publisher's output.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to observe.
    ///   - action: An optional throwing action to perform before waiting for the publisher's output.
    ///   - handler: A closure that performs custom assertions on the emitted value.
    ///   - timeout: The maximum time to wait for the publisher to emit a value.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this method was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this method was called.
    ///
    /// Example Usage:
    /// ```
    /// let myPublisher = Just(5).eraseToAnyPublisher()
    /// await assertOnNextEmit(
    ///     from: myPublisher,
    ///     when: {
    ///         /* Perform throwing action */
    ///     },
    ///     then: { nextValue in
    ///         XCTAssertEqual(nextValue, 5, "Expected next value to be 5")
    ///     },
    ///     timeout: 1.0
    /// )
    /// ```
    func assertOnNextEmit<T: Publisher>(
        from publisher: T,
        when action: () throws -> Void = {},
        then handler: @escaping (T.Output) -> Void,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        let action: () async -> Void = { try? action() }

        await assertOnNextEmit(
            from: publisher,
            when: action,
            then: handler,
            timeout: timeout,
            file: file, line: line
        )
    }

    /// Asserts a custom condition on the next emitted value from the publisher within a specified timeout, after performing an optional synchronous action.
    ///
    /// This method is suitable for cases where a simple synchronous action is performed before asserting the publisher's output.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to observe.
    ///   - action: An optional synchronous action to perform before waiting for the publisher's output.
    ///   - handler: A closure that performs custom assertions on the emitted value.
    ///   - timeout: The maximum time to wait for the publisher to emit a value.
    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this method was called.
    ///   - line: The line number on which failure occurred. Defaults to the line number on which this method was called.
    ///
    /// Example Usage:
    /// ```
    /// let myPublisher = Just(5).eraseToAnyPublisher()
    /// await assertOnNextEmit(
    ///     from: myPublisher,
    ///     when: {
    ///         /* Perform synchronous action */
    ///     },
    ///     then: { nextValue in
    ///         XCTAssertEqual(nextValue, 5, "Expected next value to be 5")
    ///     },
    ///     timeout: 1.0
    /// )     
    /// ```
    func assertOnNextEmit<T: Publisher>(
        from publisher: T,
        when action: () -> Void = {},
        then handler: @escaping (T.Output) -> Void,
        timeout: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let action: () async -> Void = { action() }

        await assertOnNextEmit(
            from: publisher,
            when: action,
            then: handler,
            timeout: timeout,
            file: file, line: line
        )
    }
}
