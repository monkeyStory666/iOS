import Testing
import MEGASwift

struct CollectionExtensionsTests {
    @Test func safeSubscript_withValidAndInvalidIndices_returnsExpectedElements() {
        let array = [1, 2, 3, 4, 5]

        #expect(array[safe: 0] == 1, "Expected element at index 0 to be 1")
        #expect(array[safe: 4] == 5, "Expected element at index 4 to be 5")
        #expect(array[safe: 5] == nil, "Expected element at index 5 to be nil (out of bounds)")
        #expect(array[safe: -1] == nil, "Expected element at index -1 to be nil (out of bounds)")
    }

    @Test func isNotEmpty_withEmptyAndNonEmptyCollections_returnsExpectedBoolean() {
        let emptyArray: [Int] = []
        let nonEmptyArray = [1, 2, 3]

        #expect(emptyArray.isNotEmpty == false, "Expected empty array to be not empty")
        #expect(nonEmptyArray.isNotEmpty, "Expected non-empty array to be not empty")

        let emptySet: Set<Int> = []
        let nonEmptySet: Set = [1, 2, 3]

        #expect(emptySet.isNotEmpty == false, "Expected empty set to be not empty")
        #expect(nonEmptySet.isNotEmpty, "Expected non-empty set to be not empty")
    }
}
