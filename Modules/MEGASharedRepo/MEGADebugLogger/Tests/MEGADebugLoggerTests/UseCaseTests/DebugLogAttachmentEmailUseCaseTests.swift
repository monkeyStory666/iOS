// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGADebugLogger
import Foundation
import MEGALogger
import MEGALoggerMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct DebugLogAttachmentEmailUseCaseTests {
    @Test func createEmailFormat_shouldAddAttachmentDataFromLoggingUseCase() async {
        let expectedFileName = String.random()
        let expectedURL = URL(string: "file://mockpath/\(expectedFileName)")!
        let expectedData = "debugLogsData".data(using: .utf8)!

        let supportEmailEntity = EmailEntity(
            recipients: [.random(), .random(), .random()],
            subject: .random(),
            body: .random()
        )
        let mockLoggingUseCase = MockLoggingUseCase(
            logFiles: .success([expectedURL])
        )
        var dataContentsOfURLCalls = [URL]()

        let sut = makeSUT(
            supportEmailFormatUseCase: MockEmailFormatUseCase(
                createEmailFormat: supportEmailEntity
            ),
            loggingUseCase: mockLoggingUseCase,
            dataContentsOfURL: {
                dataContentsOfURLCalls.append($0)
                return expectedData
            }
        )

        let result = await sut.createEmailFormat()

        #expect(
            result == EmailEntity(
                recipients: supportEmailEntity.recipients,
                subject: supportEmailEntity.subject,
                body: supportEmailEntity.body,
                attachments: [
                    EmailAttachmentEntity(
                        data: expectedData,
                        mimeType: "text/plain",
                        filename: expectedFileName
                    )
                ]
            )
        )
        #expect(dataContentsOfURLCalls == [expectedURL])
    }

    @Test func createEmailFormat_whenLogFilesError_shouldReturnSupportEmailEntity() async {
        let supportEmailEntity = EmailEntity(
            recipients: [.random(), .random(), .random()],
            subject: .random(),
            body: .random()
        )
        let sut = makeSUT(
            supportEmailFormatUseCase: MockEmailFormatUseCase(
                createEmailFormat: supportEmailEntity
            ),
            loggingUseCase: MockLoggingUseCase(
                logFiles: .failure(ErrorInTest())
            )
        )

        let result = await sut.createEmailFormat()

        #expect(
            result == EmailEntity(
                recipients: supportEmailEntity.recipients,
                subject: supportEmailEntity.subject,
                body: supportEmailEntity.body,
                attachments: []
            )
        )
    }

    @Test func createEmailFormat_whenDataContentsOfURLError_shouldContinue() async {
        let supportEmailEntity = EmailEntity(
            recipients: [.random(), .random(), .random()],
            subject: .random(),
            body: .random()
        )
        let mockLoggingUseCase = MockLoggingUseCase(
            logFiles: .success([.random])
        )

        let sut = makeSUT(
            supportEmailFormatUseCase: MockEmailFormatUseCase(
                createEmailFormat: supportEmailEntity
            ),
            loggingUseCase: mockLoggingUseCase,
            dataContentsOfURL: { _ in throw ErrorInTest() }
        )

        let result = await sut.createEmailFormat()

        #expect(
            result == EmailEntity(
                recipients: supportEmailEntity.recipients,
                subject: supportEmailEntity.subject,
                body: supportEmailEntity.body,
                attachments: []
            )
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        supportEmailFormatUseCase: any EmailFormatUseCaseProtocol = MockEmailFormatUseCase(),
        loggingUseCase: any LoggingUseCaseProtocol = MockLoggingUseCase(),
        dataContentsOfURL: @escaping (URL) throws -> Data = { _ in Data() }
    ) -> DebugLogAttachmentEmailUseCase {
        DebugLogAttachmentEmailUseCase(
            supportEmailFormatUseCase: supportEmailFormatUseCase,
            loggingUseCase: loggingUseCase,
            dataContentsOfURL: dataContentsOfURL
        )
    }
}
