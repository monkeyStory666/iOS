// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAuthentication
import Testing

struct ConfirmPasswordIssuesTests {
    @Test func testConfirmPasswordIsEmpty() {
        let issues = ConfirmPasswordIssues(newPassword: .random(), confirmPassword: "")

        #expect(issues.contains(.emptyPassword))
    }

    @Test func testConfirmPasswordIsNotEmpty() {
        let issues = ConfirmPasswordIssues(newPassword: "", confirmPassword: .random())

        #expect(issues.contains(.emptyPassword) == false)
    }

    @Test func testPasswordsDoNotMatch() {
        let issues = ConfirmPasswordIssues(
            newPassword: "newPassword",
            confirmPassword: "confirmPassword"
        )

        #expect(issues.contains(.doesNotMatch))
    }

    @Test func testPasswordsMatch() {
        let issues = ConfirmPasswordIssues(
            newPassword: "matchedPassword",
            confirmPassword: "matchedPassword"
        )

        #expect(issues.contains(.doesNotMatch) == false)
    }
}
