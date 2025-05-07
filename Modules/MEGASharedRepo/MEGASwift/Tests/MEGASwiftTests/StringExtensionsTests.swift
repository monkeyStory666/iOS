import Testing
import MEGASwift

struct StringExtensionsTests {
    @Test func emptyString_shouldBeEmpty() {
        #expect(String.empty == "")
    }

    @Test func isNotEmpty_withVariousStrings_returnsExpectedResults() {
        #expect("Hello".isNotEmpty)
        #expect("".isNotEmpty == false)
    }

    @Test func isNotEmptyOrWhitespace_withVariousStrings_returnsExpectedResults() {
        #expect("Hello".isNotEmptyOrWhitespace)
        #expect("".isNotEmptyOrWhitespace == false)
        #expect("    ".isNotEmptyOrWhitespace == false)
        #expect("\n\t".isNotEmptyOrWhitespace == false)
        #expect("Hello world".isNotEmptyOrWhitespace)
        #expect("    Hello".isNotEmptyOrWhitespace)
    }

    @Test func digits_withMixedString_returnsOnlyDigits() {
        let string = "a1b2c3"
        let result = string.digits
        #expect(
            result ==
            [1, 2, 3],
            "Expected the digits array to contain [1, 2, 3]."
        )
    }

    @Test func masked_withString_returnsMaskedString() {
        let string = "password"
        let result = string.masked()
        #expect(
            result ==
            "••••••••",
            "Expected the masked string to be '••••••••'."
        )
    }
}
