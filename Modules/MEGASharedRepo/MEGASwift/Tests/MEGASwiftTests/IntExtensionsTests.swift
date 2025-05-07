import Testing
import MEGASwift

struct IntExtensionsTests {
    func testDigitString_singleDigitIntegers_returnsCorrectString() {
        #expect(0.digitString == "0", "Expected digitString of 0 to be '0'")
        #expect(1.digitString == "1", "Expected digitString of 1 to be '1'")
        #expect(9.digitString == "9", "Expected digitString of 9 to be '9'")
    }

    func testDigitString_integersGreaterThanOrEqualTo10_returnsZeroString() {
        #expect(10.digitString == "0", "Expected digitString of 10 to be '0'")
        #expect(15.digitString == "0", "Expected digitString of 15 to be '0'")
        #expect(123.digitString == "0", "Expected digitString of 123 to be '0'")
    }
}
