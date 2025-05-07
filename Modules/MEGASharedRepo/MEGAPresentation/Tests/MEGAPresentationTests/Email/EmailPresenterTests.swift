// Copyright © 2023 MEGA Limited. All rights reserved.

import Testing
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGAPresentation
import MEGAPresentationMocks

struct EmailPresenterTests {
    @Test func presentMailCompose_shouldStart_andStopLoading() async {
        let mockAppLoadingManager = MockAppLoadingStateManager()
        let sut = makeSUT(appLoadingManager: mockAppLoadingManager)

        await sut.presentMailCompose()

        mockAppLoadingManager.swt.assertActions(shouldBe: [.startLoading(.init()), .stopLoading])
    }

    @Test func presentMailCompose_shouldOpenExternalLink_withFormattedMailToURL() async {
        let expectedEmailEntity = EmailEntity.dummy()
        let mockLinkOpener = MockExternalLinkOpener()
        let mockUseCase = MockEmailFormatUseCase(createEmailFormat: expectedEmailEntity)
        let sut = makeSUT(
            emailFormatUseCase: mockUseCase,
            externalLinkOpener: mockLinkOpener
        )

        await sut.presentMailCompose()

        mockLinkOpener.swt.assertActions(
            shouldBe: [.openExternalLink(
                expectedEmailEntity.mailToURL!
            )]
        )
    }

    // MARK: - Test Helpers

    private typealias SUT = EmailPresenter

    private func makeSUT(
        emailFormatUseCase: some EmailFormatUseCaseProtocol = MockEmailFormatUseCase(),
        externalLinkOpener: some ExternalLinkOpening = MockExternalLinkOpener(),
        appLoadingManager: some AppLoadingStateManagerProtocol = MockAppLoadingStateManager()
    ) -> SUT {
        SUT(
            emailFormatUseCase: emailFormatUseCase,
            externalLinkOpener: externalLinkOpener,
            appLoadingManager: appLoadingManager
        )
    }
}
