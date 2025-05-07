@testable import MEGAAuthentication
import Testing

struct FieldStateTests {
    @Test func isWarning() {
        #expect(FieldState.warning("anyString").isWarning)
        #expect(FieldState.normal.isWarning == false)
    }
}
