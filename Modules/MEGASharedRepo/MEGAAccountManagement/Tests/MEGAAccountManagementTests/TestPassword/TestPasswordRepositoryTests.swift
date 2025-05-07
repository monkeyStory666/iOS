// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGATest
import Testing

struct TestPasswordRepositoryTests {
    @Test func testTestPassword_shouldReturnSdkCheckPassword() async {
        func assert(
            whenSdkCheckPassword sdkCheckPassword: Bool,
            shouldReturn expectedResult: Bool,
            line: UInt = #line
        ) async {
            let sdk = MockTestPasswordSdk(checkPassword: sdkCheckPassword)
            let sut = makeSUT(sdk: sdk)

            let passwordInput = String.random()
            let result = await sut.testPassword(passwordInput)

            #expect(result == expectedResult)
            #expect(sdk.checkPasswordCalls == [passwordInput])
        }

        await assert(whenSdkCheckPassword: true, shouldReturn: true)
        await assert(whenSdkCheckPassword: false, shouldReturn: false)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockTestPasswordSdk = MockTestPasswordSdk()
    ) -> TestPasswordRepository {
        TestPasswordRepository(sdk: sdk)
    }
}

private final class MockTestPasswordSdk: MEGASdk, @unchecked Sendable {
    var checkPasswordCalls = [String]()

    var _checkPassword: Bool

    init(checkPassword: Bool = true) {
        self._checkPassword = checkPassword
        super.init()
    }

    override func checkPassword(_ password: String) -> Bool {
        checkPasswordCalls.append(password)
        return _checkPassword
    }
}
