import Testing
import MEGASwift

struct FloatCleanStringValueTests {
    @Test func cleanStringValue() {
        #expect(Float(10.0).cleanStringValue == "10")
        #expect(Float(3.14159).cleanStringValue == "3")
        #expect(Float(-5.0).cleanStringValue == "-5")
        #expect(Float(0.123456).cleanStringValue == "0")
    }
}
