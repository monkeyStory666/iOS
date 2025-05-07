// Copyright © 2023 MEGA Limited. All rights reserved.

import Testing
import MEGAInfrastructure
import MEGAInfrastructureMocks

struct FeedbackEmailFormatUseCaseTests {
    @Test func createEmailFormat() async throws {
        let mockDiagnostic = MockDiagnosticReadable()
        let sut = makeSUT(
            recipients: ["any@mega.co.nz"],
            diagnosticReadable: mockDiagnostic
        )

        let emailEntity = await sut.createEmailFormat()
        #expect(emailEntity.recipients == ["any@mega.co.nz"])
        #expect(emailEntity.subject.contains("Feedback"))
        #expect(emailEntity.body.contains("<br>") == false)
        await assert(emailEntity, containsDiagnosticFrom: mockDiagnostic)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        recipients: [String] = ["any@mega.co.nz"],
        diagnosticReadable: MockDiagnosticReadable = MockDiagnosticReadable()
    ) -> FeedbackEmailFormatUseCase {
        FeedbackEmailFormatUseCase(
            recipients: recipients,
            diagnosticReadable: diagnosticReadable
        )
    }

    private func assert(
        _ emailEntity: EmailEntity,
        containsDiagnosticFrom diagnosticReadable: DiagnosticReadable
    ) async {
        let completeDiagnostic = await diagnosticReadable.readableDiagnostic()

        #expect(emailEntity.body.contains(completeDiagnostic))
    }
}

