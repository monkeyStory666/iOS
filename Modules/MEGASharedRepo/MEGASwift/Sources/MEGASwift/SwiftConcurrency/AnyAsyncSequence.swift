import Foundation

/// An async sequence that performs type erasure by wrapping another async sequence.
public struct AnyAsyncSequence<Element>: AsyncSequence, Sendable {
    private let generateIterator: @Sendable () -> Iterator
    
    public init<S>(_ sequence: S) where S: AsyncSequence, S.Element == Element, S: Sendable, S.Element: Sendable {
        generateIterator = { Iterator(sequence.makeAsyncIterator()) }
    }
    
    public func makeAsyncIterator() -> Iterator {
        generateIterator()
    }
    
    public struct Iterator: AsyncIteratorProtocol {
        private let generateNext: () async -> Element?
        
        public init<I>(_ iterator: I) where I: AsyncIteratorProtocol, I.Element == Element {
            var iterator = iterator
            generateNext = { try? await iterator.next() }
        }
        
        mutating public func next() async -> Element? {
            await generateNext()
        }
    }
}

@available(*, unavailable)
extension AnyAsyncSequence.Iterator: Sendable { }

/// An async throwing sequence that performs type erasure by wrapping another async sequence.
public struct AnyAsyncThrowingSequence<Element, Failure>: AsyncSequence, Sendable where Failure: Error {
    private let generateIterator: @Sendable () -> Iterator
    
    public init<S>(_ sequence: S) where S: AsyncSequence, S.Element == Element, Failure == any Error, S: Sendable, S.Element: Sendable {
        generateIterator = { Iterator(sequence.makeAsyncIterator()) }
    }
    
    public func makeAsyncIterator() -> Iterator {
        generateIterator()
    }
    
    public struct Iterator: AsyncIteratorProtocol {
        private let generateNext: () async throws -> Element?
        
        public init<I>(_ iterator: I) where I: AsyncIteratorProtocol, I.Element == Element {
            var iterator = iterator
            generateNext = { try await iterator.next() }
        }
        
        mutating public func next() async throws -> Element? {
            try await generateNext()
        }
    }
}

@available(*, unavailable)
extension AnyAsyncThrowingSequence.Iterator: Sendable { }
