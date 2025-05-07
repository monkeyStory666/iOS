struct MockAsyncThrowingSequence<Element>: AsyncSequence {
    typealias AsyncIterator = Iterator

    let elements: [Element]
    let error: (any Error)?

    struct Iterator: AsyncIteratorProtocol {
        var iterator: IndexingIterator<[Element]>
        let error: (any Error)?

        mutating func next() async throws -> Element? {
            if let error = error {
                throw error
            }
            return iterator.next()
        }
    }

    func makeAsyncIterator() -> Iterator {
        return Iterator(iterator: elements.makeIterator(), error: error)
    }
}

extension MockAsyncThrowingSequence: Sendable where Element: Sendable { }
extension MockAsyncThrowingSequence.Iterator: Sendable where Element: Sendable { }
