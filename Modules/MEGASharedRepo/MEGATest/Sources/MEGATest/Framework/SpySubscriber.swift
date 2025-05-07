// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine

/// `SpySubscriber` is a utility to test Combine publishers.
/// It subscribes to a publisher and stores all values it emits and the completion event.
/// Use the `values` property to inspect the values that were emitted by the publisher,
/// and the `completion` property to inspect how the publisher completed.
public final class SpySubscriber<Output, Failure: Error>: Subscriber {
    public typealias Input = Output
    public typealias Failure = Failure

    /// The values that were emitted by the publisher.
    public var values = [Output]()

    /// The event that indicates how the publisher completed.
    /// This will be nil if the publisher has not yet completed.
    public var completion: Subscribers.Completion<Failure>?

    public func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: Output) -> Subscribers.Demand {
        values.append(input)
        return .none
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        self.completion = completion
    }
}

public extension Publisher {
    /// Creates a `SpySubscriber` and subscribes it to this publisher.
    ///
    /// - Returns: A `SpySubscriber` which you can use to inspect what values were emitted by the publisher.
    ///
    /// - Note: Be sure to keep a reference to the returned `SpySubscriber` for as long as you want to test this publisher.
    ///         If the `SpySubscriber` is deallocated, it will cancel the subscription.
    ///
    /// # Usage:
    /// ```
    /// let publisher = // Your publisher
    /// let spy = publisher.spy()
    /// // Trigger publisher emissions, e.g. by calling a method on your object under test
    /// ...
    /// XCTAssertEqual(spy.values, [expectedValue1, expectedValue2])
    /// XCTAssert(spy.completion == .finished || spy.completion == .failure(expectedError))
    /// ```
    func spy() -> SpySubscriber<Output, Failure> {
        let subscriber = SpySubscriber<Output, Failure>()
        self.subscribe(subscriber)
        return subscriber
    }
}
