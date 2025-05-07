import Foundation

/// An asynchronous sequence that produces no elements.
///
/// `EmptyAsyncSequence` is an `AsyncSequence` that immediately completes without yielding any elements.
/// Use this sequence when an async sequence is required by an API, but you have no values to produce.
public struct EmptyAsyncSequence<Element>: AsyncSequence {
    /// Creates an empty async sequence.
    public init() { }
    
    /// An asynchronous iterator over an empty sequence.
    public struct Iterator: AsyncIteratorProtocol {
        /// Always returns `nil` to indicate that there are no elements in the sequence.
        ///
        /// - Returns: Always `nil`.
        mutating public func next() async -> Element? {
             nil
        }
    }
    
    /// Creates an asynchronous iterator over the empty sequence.
    ///
    /// - Returns: An iterator that produces no elements.
    public func makeAsyncIterator() -> Iterator {
        Iterator()
    }
}

/// Conformance to `Sendable` for `EmptyAsyncSequence` when `Element` is `Sendable`.
extension EmptyAsyncSequence: Sendable where Element: Sendable { }

/// Conformance to `Sendable` for `EmptyAsyncSequence.Iterator` when `Element` is `Sendable`.
extension EmptyAsyncSequence.Iterator: Sendable where Element: Sendable { }
