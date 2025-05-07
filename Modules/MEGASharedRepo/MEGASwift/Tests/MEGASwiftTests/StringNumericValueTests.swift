import Testing
import MEGASwift

struct StringNumericValueTests {
    @Test func numericValue_withNumericString_returnsOriginalString() {
        let inputString = "123456"
        let numericValue = inputString.numericValue
        #expect(numericValue == inputString, "Numeric value should be equal to original string.")
    }

    @Test func numericValue_withAlphaNumericString_returnsNumericCharactersOnly() {
        let inputString = "abc123def456"
        let numericValue = inputString.numericValue
        #expect(numericValue == "123456", "Numeric value should contain only numeric characters.")
    }

    @Test func numericValue_withEmptyString_returnsEmptyString() {
        let inputString = ""
        let numericValue = inputString.numericValue
        #expect(numericValue == "", "Numeric value of an empty string should also be an empty string.")
    }

    @Test func numericValue_withNonNumericString_returnsEmptyString() {
        let inputString = "abc"
        let numericValue = inputString.numericValue
        #expect(numericValue == "", "Numeric value of a non-numeric string should be an empty string.")
    }
}

