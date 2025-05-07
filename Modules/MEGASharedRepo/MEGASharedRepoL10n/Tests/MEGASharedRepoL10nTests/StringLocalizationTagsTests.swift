// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASharedRepoL10n
import Testing

struct StringLocalizationTagsTests {
    // MARK: - Assign Link for Tag

    @Test func assignLinkForTagWithMatchingURLs() {
        #expect(
            "This is a test [L1]first Link[/L1] and another [L2]second Link[/L2]"
                .assignLink(URL(string: "https://example1.com")!, forTag: "L1")
                .assignLink(URL(string: "https://example2.com")!, forTag: "L2") ==
            "This is a test [first Link](https://example1.com) and another [second Link](https://example2.com)"
        )
    }

    @Test func assignLinkForTag_withTagsRemaining_shouldNotAffectTheRemainingTag() {
        #expect(
            "This is a test [L1]link1[/L1] and another [L2]link2[/L2]"
                .assignLink(URL(string: "https://example.com")!, forTag: "L1") ==
            "This is a test [link1](https://example.com) and another [L2]link2[/L2]"
        )
    }

    @Test func assignLinkForTag_withDuplicateTag_shouldAssignToBoth() {
        #expect(
            "This is a test [L]link1[/L] and another [L]link2[/L]"
                .assignLink(URL(string: "https://example.com")!, forTag: "L") ==
            "This is a test [link1](https://example.com) and another [link2](https://example.com)"
        )
    }

    @Test func assignLinkForTag_whenTagNotExit_shouldReturnOriginalString() {
        #expect(
            "This is a test [L1]link1[/L1] and another [L2]link2[/L2]"
                .assignLink(URL(string: "https://example.com")!, forTag: "L3") ==
            "This is a test [L1]link1[/L1] and another [L2]link2[/L2]"
        )
    }

    @Test func assignLinkForTag_withNonEnglishCharacters() {
        #expect(
            "これはテストです [L1]リンク[/L1]"
                .assignLink(URL(string: "https://example.com")!, forTag: "L1") ==
            "これはテストです [リンク](https://example.com)"
        )
    }

    // MARK: - Remove All Translation Tags

    @Test func removeAllTranslationTags_fromStringWithOneTag() {
        #expect(
            "This is a test [A]alpha[/A]"
                .removeAllLocalizationTags() ==
            "This is a test alpha"
        )
    }

    @Test func removeAllTranslationTags_fromStringWithTag_ofMultipleCharacters() {
        #expect(
            "This is a test [A2]alpha[/A2]"
                .removeAllLocalizationTags() ==
            "This is a test alpha"
        )
    }

    @Test func removeAllTranslationTags_fromStringWithMultipleTags() {
        #expect(
            "This is a test [L]link1[/L], [A]alpha[/A], and [Z]zeta[/Z]"
                .removeAllLocalizationTags() ==
            "This is a test link1, alpha, and zeta"
        )
    }

    @Test func removeAllTranslationTags_fromStringWithNestedTags() {
        #expect(
            "This is a test [A][L]link[/L][/A]"
                .removeAllLocalizationTags() ==
            "This is a test link"
        )
    }

    @Test func removeAllTranslationTagsWithNoTags() {
        #expect(
            "This is a test without tags"
                .removeAllLocalizationTags() ==
            "This is a test without tags"
        )
    }

    @Test func removeAllTranslationTagsWithNonEnglishCharacters() {
        #expect(
            "これはテストです [L]リンク[/L], Пример [P]текст[/P]"
                .removeAllLocalizationTags() ==
            "これはテストです リンク, Пример текст"
        )
    }

    // MARK: - Get Localization Substring with Tag String

    @Test func getLocalizationSubstringWithEmptyString() {
        let testString = ""
        #expect(
            testString.getLocalizationSubstring(tag: "A") ==
            ""
        )
    }

    @Test func getLocalizationSubstringWithSingleTag() {
        #expect(
            "Only one tag [A]alpha[/A]"
                .getLocalizationSubstring(tag: "A") ==
            "alpha"
        )
    }

    @Test func getLocalizationSubstringWithValidTag() {
        #expect(
            "This is a test [L]link1[/L], [A]alpha[/A], and [Z]zeta[/Z]"
                .getLocalizationSubstring(tag: "A") ==
            "alpha"
        )
    }

    @Test func getLocalizationSubstringWithInvalidTag() {
        #expect(
            "This is a test [L]link1[/L], [A]alpha[/A], and [Z]zeta[/Z]"
                .getLocalizationSubstring(tag: "B") ==
            ""
        )
    }

    @Test func getLocalizationSubstringWithNoTags() {
        #expect(
            "This is a test without tags"
                .getLocalizationSubstring(tag: "A") ==
            ""
        )
    }

    @Test func getLocalizationSubstringWithNonEnglishCharacters() {
        let testString = "これはテストです [L]リンク[/L], Пример [P]текст[/P]"

        #expect(
            testString
                .getLocalizationSubstring(tag: "L") ==
            "リンク"
        )

        #expect(
            testString
                .getLocalizationSubstring(tag: "P") ==
            "текст"
        )
    }

    @Test func getLocalizationSubstringWithNestedTag() {
        let testString = "Only one tag [A]alpha [B]beta [C]gamma[/C][/B][/A]"

        #expect(
            testString.getLocalizationSubstring(tag: "A") ==
            "alpha beta gamma"
        )
        #expect(
            testString.getLocalizationSubstring(tag: "B") ==
            "beta gamma"
        )
        #expect(
            testString.getLocalizationSubstring(tag: "C") ==
            "gamma"
        )
    }

    @Test func getLocalizationSubstringWithNestedTag_withoutRemovingNestedTags() {
        let testString = "Only one tag [A]alpha [B]beta [C]gamma[/C][/B][/A]"

        #expect(
            testString.getLocalizationSubstring(tag: "A", removeNestedTags: false) ==
            "alpha [B]beta [C]gamma[/C][/B]"
        )
        #expect(
            testString.getLocalizationSubstring(tag: "B", removeNestedTags: false) ==
            "beta [C]gamma[/C]"
        )
        #expect(
            testString.getLocalizationSubstring(tag: "C", removeNestedTags: false) ==
            "gamma"
        )
    }
}
