@testable import MEGASwift
import Testing

struct AsyncSequenceExtensionsTests {
    @Test func asyncMap_withValidSequence_hasTransformation() async throws {
        let sequence = [1, 2, 3]
        let result = await sequence.asyncMap { element in
            return "\(element)"
        }
        #expect(
            result == ["1", "2", "3"],
            "Expected the transformed array to contain string representations of the integers."
        )
    }

    @Test func asyncForEach_withValidSequence_executesOperation() async throws {
        let sequence = [1, 2, 3]
        var result = [Int]()
        await sequence.asyncForEach { element in
            result.append(element)
        }
        #expect(
            result == sequence,
            "Expected the result array to contain the same elements as the input sequence."
        )
    }

    @Test func concurrentForEach_withValidSequence_completesConcurrently() async {
        let sequence = [1, 2, 3]
        let resultCollector = ResultCollector<Int>()

        await sequence.concurrentForEach { element in
            await resultCollector.append(element)
        }

        let result = await resultCollector.getElements()
        #expect(
            result.sorted() == sequence,
            "Expected the result array to contain the same elements as the input sequence."
        )
    }

    @Test func concurrentMap_withValidSequence_transformsElementsCorrectly() async throws {
        let sequence = [1, 2, 3]
        let result = await sequence.concurrentMap { element in
            return "\(element)"
        }
        #expect(
            result == ["1", "2", "3"],
            "Expected the transformed array to contain string representations of the integers."
        )
    }
}


actor ResultCollector<Element> {
    private var elements = [Element]()

    func append(_ element: Element) {
        elements.append(element)
    }

    func getElements() -> [Element] {
        return elements
    }
}
