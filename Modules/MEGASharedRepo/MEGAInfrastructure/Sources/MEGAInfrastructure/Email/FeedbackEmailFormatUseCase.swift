// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct FeedbackEmailFormatUseCase: EmailFormatUseCaseProtocol {
    private let recipients: [String]
    private let diagnosticReadable: any DiagnosticReadable

    public init(
        recipients: [String],
        diagnosticReadable: some DiagnosticReadable
    ) {
        self.recipients = recipients
        self.diagnosticReadable = diagnosticReadable
    }

    public func createEmailFormat() async -> EmailEntity {
        EmailEntity(
            recipients: recipients,
            subject: await feedbackSubject(),
            body: await getFeedbackMessageString()
        )
    }

    private func feedbackSubject() async -> String {
        "Feedback \(AppInformation().appName)"
    }

    private func getFeedbackMessageString() async -> String {
        """
        Please write your feedback here:
        \(feedbackMessageSpace)
        \(await diagnosticReadable.readableDiagnostic())
        """
    }

    private var feedbackMessageSpace: String { Array(repeating: "\n", count: 8).joined() }
}
