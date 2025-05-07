// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGALogger

struct DebugLogAttachmentEmailUseCase: EmailFormatUseCaseProtocol {
    private let supportEmailFormatUseCase: EmailFormatUseCaseProtocol
    private let loggingUseCase: LoggingUseCaseProtocol
    private let dataContentsOfURL: (URL) throws -> Data

    init(
        supportEmailFormatUseCase: some EmailFormatUseCaseProtocol,
        loggingUseCase: some LoggingUseCaseProtocol,
        dataContentsOfURL: @escaping (URL) throws -> Data
    ) {
        self.supportEmailFormatUseCase = supportEmailFormatUseCase
        self.loggingUseCase = loggingUseCase
        self.dataContentsOfURL = dataContentsOfURL
    }

    func createEmailFormat() async -> EmailEntity {
        let supportEmailEntity = await supportEmailFormatUseCase.createEmailFormat()

        return EmailEntity(
            recipients: supportEmailEntity.recipients,
            subject: supportEmailEntity.subject,
            body: supportEmailEntity.body,
            attachments: attachmentData()
        )
    }

    private func attachmentData() -> [EmailAttachmentEntity] {
        let logFilesURLs = (try? loggingUseCase.logFiles()) ?? []
        var dataFiles = [EmailAttachmentEntity]()

        for url in logFilesURLs {
            guard let data = try? dataContentsOfURL(url) else { continue }

            dataFiles.append(
                EmailAttachmentEntity(
                    data: data,
                    mimeType: "text/plain",
                    filename: url.lastPathComponent
                )
            )
        }

        return dataFiles
    }
}
