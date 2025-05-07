// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAuthentication
import Testing

struct NewPasswordIssuesTests {
    @Test func testPasswordLessThanMinimumCharacters() {
        #expect(
            NewPasswordIssues(
                from: .random(length: NewPasswordIssues.minimumCharacters - 1)
            ).contains(.lessThanMinimumCharacters)
        )
        #expect(
            NewPasswordIssues(
                from: .random(length: 1)
            ).contains(.lessThanMinimumCharacters)
        )
    }

    @Test func testPasswordAtLeastMinimumCharacters() {
        #expect(
            NewPasswordIssues(
                from: .random(length: NewPasswordIssues.minimumCharacters)
            ).contains(.lessThanMinimumCharacters) == false
        )
        #expect(
            NewPasswordIssues(
                from: .random(length: NewPasswordIssues.minimumCharacters + 1)
            ).contains(.lessThanMinimumCharacters) == false
        )
    }
}
