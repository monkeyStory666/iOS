import Foundation
import Testing
import MEGASwift

fileprivate enum TestError: Error {
    case test1
    case test2
}

struct ErrorMatchingTests {
    @Test
    func isError_equalToTheSameTypeAndCase_shouldReturnTrue() {
        let error = TestError.test2
        let otherError = TestError.test2

        #expect(
            isError(error, equalTo: otherError),
            "Expected the error to match the specified type and case"
        )
    }

    @Test
    func isError_equalToTheDifferentType_shouldReturnFalse() {
        let error = TestError.test2
        let otherError = NSError(domain: "testDomain", code: 123, userInfo: nil)

        #expect(
            !isError(error, equalTo: otherError),
            "Expected the error not to match the specified type"
        )
    }
}
