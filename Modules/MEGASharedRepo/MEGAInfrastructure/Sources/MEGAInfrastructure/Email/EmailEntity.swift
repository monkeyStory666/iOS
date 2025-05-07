// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct EmailEntity: Identifiable, Equatable, Sendable {
    public let recipients: [String]
    public let subject: String
    public let body: String
    public let attachments: [EmailAttachmentEntity]

    public var id: String {
        mailToURL?.absoluteString ?? ""
    }

    public var mailToURL: URL? {
        guard !recipients.isEmpty else { return nil }

        let emailAddress = recipients.joined(separator: ",")
        var components = URLComponents(string: "mailto:\(emailAddress)")
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "subject", value: subject))
        queryItems.append(URLQueryItem(name: "body", value: body))
        components?.queryItems = queryItems
        return components?.url
    }

    public init(
        recipients: [String],
        subject: String,
        body: String,
        attachments: [EmailAttachmentEntity] = []
    ) {
        self.recipients = recipients
        self.subject = subject
        self.body = body
        self.attachments = attachments
    }
}

public struct EmailAttachmentEntity: Equatable, Sendable {
    public let data: Data
    public let mimeType: String
    public let filename: String

    public init(
        data: Data,
        mimeType: String,
        filename: String
    ) {
        self.data = data
        self.mimeType = mimeType
        self.filename = filename
    }
}

public extension EmailEntity {
    init?(from mailtoLink: String) {
        guard
            let url = URL(string: mailtoLink),
            url.scheme == "mailto",
            let recipientPart = url.absoluteString
                .components(separatedBy: "?")
                .first?
                .replacingOccurrences(of: "mailto:", with: "")
        else {
            return nil
        }

        self.recipients = recipientPart
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }

        let queryItems = URLComponents(string: mailtoLink)?.queryItems
        self.subject = queryItems?
            .first(where: { $0.name == "subject" })?
            .value ?? ""
        self.body = queryItems?
            .first(where: { $0.name == "body" })?
            .value?
            .replacingOccurrences(of: "%0A", with: "\n") ?? ""
        self.attachments = []
    }
}
