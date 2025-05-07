// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAuthentication
import Testing

struct PasswordRecommendationsTests {
    @Test(
        arguments: [
            "passworD",
            "Password",
            "PaSsWoRd",
            "PaSsW0Rd"
        ]
    ) func testContainsUppercaseAndLowercase(newPassword: String) {
        #expect(
            PasswordRecommendations(
                for: newPassword
            ).contains(.upperAndLowercaseLetters)
        )
    }

    @Test(
        arguments: [
            "password1",
            "p4ssword",
            "pa$$word"
        ]
    ) func testDoesNotContainUppercaseAndLowercase(newPassword: String) {
        #expect(
            PasswordRecommendations(
                for: newPassword
            ).contains(.upperAndLowercaseLetters) == false
        )
    }

    @Test(
        arguments: [
            "password1",
            "p4ssword",
            "pa$$word",
            "p4$$worD"
        ]
    ) func testContainsNumberOrSpecialCharacter(newPassword: String) {
        #expect(
            PasswordRecommendations(
                for: newPassword
            ).contains(.oneNumberOrSpecialCharacter)
        )
    }

    @Test(
        arguments: [
            "passworD",
            "Password",
            "PaSsWoRd"
        ]
    ) func testDoesNotContainsNumberOrSpecialCharacter(newPassword: String) {
        #expect(
            PasswordRecommendations(
                for: newPassword
            ).contains(.oneNumberOrSpecialCharacter) == false
        )
    }
}
