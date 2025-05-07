import Foundation

/// An asynchronous sequence that produces a single element and then finishes.
///
/// This sequence is useful when you need to provide a single value asynchronously in an API
/// that expects an `AsyncSequence`.
public struct SingleItemAsyncSequence<Element>: AsyncSequence {
    private let item: Element

    /// Creates a new single-item asynchronous sequence.
    ///
    /// - Parameter item: The single element to be produced by the sequence.
    public init(item: Element) {
        self.item = item
    }

    /// An asynchronous iterator that produces the elements of the sequence.
    public struct Iterator: AsyncIteratorProtocol {
        private var item: Element?

        /// Initializes the iterator with the provided element.
        ///
        /// - Parameter item: The single element that will be returned by the iterator.
        init(item: Element) {
            self.item = item
        }

        /// Returns the next element in the sequence asynchronously.
        ///
        /// On the first call, this method returns the element provided during initialization.
        /// Subsequent calls return `nil`, indicating that the sequence has been exhausted.
        ///
        /// - Returns: The next element of the sequence, or `nil` if there are no more elements.
        mutating public func next() async -> Element? {
            guard let item else {
                return nil
            }
            self.item = nil
            return item
        }
    }

    /// Creates an asynchronous iterator over the elements of the sequence.
    ///
    /// - Returns: An iterator that produces the single element of the sequence.
    public func makeAsyncIterator() -> Iterator {
        Iterator(item: item)
    }
}

/// Conforms `SingleItemAsyncSequence` to `Sendable` when its element type is `Sendable`.
extension SingleItemAsyncSequence: Sendable where Element: Sendable { }

/// Conforms `SingleItemAsyncSequence.Iterator` to `Sendable` when its element type is `Sendable`.
extension SingleItemAsyncSequence.Iterator: Sendable where Element: Sendable { }
