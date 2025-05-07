@testable import MEGASwift
import Foundation
import Testing

struct TimedOutErrorTests {
    @Test func isTimeoutErrorWithTimedOutError() {
        let error = TimedOutError()
        #expect(error.isTimeoutError, "TimedOutError should be recognized as a timeout error.")
    }

    @Test func isTimeoutErrorWithDifferentError() {
        struct AnotherError: Error {}
        let error = AnotherError()
        #expect(error.isTimeoutError == false, "AnotherError should not be recognized as a timeout error.")
    }

    @Test func isTimeoutErrorWithNSError() {
        let nsError = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        #expect(nsError.isTimeoutError == false, "NSError should not be recognized as a timeout error.")
    }

    @Test func isTimeoutErrorWithCustomError() {
        struct CustomError: Error {}
        let error = CustomError()
        #expect(error.isTimeoutError == false, "CustomError should not be recognized as a timeout error.")
    }
}
