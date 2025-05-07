// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import Testing

struct EmailEntityTests {
    @Test func mailToURL_withValidInputs() {
        let entity = EmailEntity(
            recipients: ["test@example.com", "another@example.com"],
            subject: "Hello",
            body: "This is a test email."
        )

        let url = entity.mailToURL
        let expectedURL = "mailto:test@example.com,another@example.com"
        + "?subject=Hello&body=This%20is%20a%20test%20email."

        #expect(
            url?.absoluteString == expectedURL,
            "The mailToURL should correctly encode recipients, subject, and body."
        )
    }

    @Test func mailToURL_withEmptyRecipients() {
        let entity = EmailEntity(
            recipients: [],
            subject: "No Recipients",
            body: "This email has no recipients."
        )

        let url = entity.mailToURL
        #expect(
            url == nil,
            "The mailToURL should return nil when there are no recipients."
        )
    }

    @Test func mailToURL_withSpecialCharacters() {
        let entity = EmailEntity(
            recipients: ["special@example.com"],
            subject: "Special Subject: &%",
            body: "Body with special characters: <>&"
        )

        let url = entity.mailToURL
        let expectedURL = "mailto:special@example.com"
        + "?subject=Special%20Subject:%20%26%25"
        + "&body=Body%20with%20special%20characters:%20%3C%3E%26"

        #expect(
            url?.absoluteString == expectedURL,
            "The mailToURL should correctly encode special characters in subject and body."
        )
    }

    @Test func initFromMailtoLink_withValidMailtoURL() {
        let mailtoLink = "mailto:test@example.com?subject=Hello&body=This%20is%20a%20test%20email."
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should create an EmailEntity from a valid mailto link."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "Hello")
        #expect(entity?.body == "This is a test email.")
    }

    @Test func initFromMailtoLink_withMultipleRecipients() {
        let mailtoLink = "mailto:test@example.com,another@example.com?"
        + "subject=Greetings&body=Hello%20everyone."

        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should handle multiple recipients."
        )
        #expect(entity?.recipients == ["test@example.com", "another@example.com"])
        #expect(entity?.subject == "Greetings")
        #expect(entity?.body == "Hello everyone.")
    }

    @Test func initFromMailtoLink_withEmptyFields() {
        let mailtoLink = "mailto:?subject=&body="
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should handle a mailto link with empty fields."
        )
        #expect(entity?.recipients == [])
        #expect(entity?.subject == "")
        #expect(entity?.body == "")
    }

    @Test func initFromMailtoLink_withInvalidMailtoURL() {
        let invalidMailtoLink = "http://example.com"
        let entity = EmailEntity(from: invalidMailtoLink)

        #expect(
            entity == nil,
            "The initializer should return nil for an invalid mailto link."
        )
    }

    @Test func initFromMailtoLink_withEncodedNewLinesInBody() {
        let mailtoLink = "mailto:test@example.com?"
        + "subject=Greetings&body=Hello%20there%0AHow%20are%20you?"
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should decode newlines in the body correctly."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "Greetings")
        #expect(entity?.body == "Hello there\nHow are you?")
    }

    @Test func initFromMailtoLink_withMissingSubject() {
        let mailtoLink = "mailto:test@example.com?body=This%20is%20a%20test%20email."
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should create an EmailEntity when subject is missing."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "")
        #expect(entity?.body == "This is a test email.")
    }

    @Test func initFromMailtoLink_withMissingBody() {
        let mailtoLink = "mailto:test@example.com?subject=Hello"
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should create an EmailEntity when body is missing."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "Hello")
        #expect(entity?.body == "")
    }

    @Test func initFromMailtoLink_withMissingSubjectAndBody() {
        let mailtoLink = "mailto:test@example.com"
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should create an EmailEntity when both subject and body are missing."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "")
        #expect(entity?.body == "")
    }

    @Test func initFromMailtoLink_withEmptyQueryItems() {
        let mailtoLink = "mailto:test@example.com?"
        let entity = EmailEntity(from: mailtoLink)

        #expect(
            entity != nil,
            "The initializer should create an EmailEntity when query items are empty."
        )
        #expect(entity?.recipients == ["test@example.com"])
        #expect(entity?.subject == "")
        #expect(entity?.body == "")
    }
}
