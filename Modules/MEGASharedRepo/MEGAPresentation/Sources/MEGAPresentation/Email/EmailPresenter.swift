// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public protocol EmailPresenting {
    func presentMailCompose() async
}

public struct EmailPresenter: EmailPresenting {
    private let emailFormatUseCase: any EmailFormatUseCaseProtocol
    private let externalLinkOpener: any ExternalLinkOpening
    private let appLoadingManager: any AppLoadingStateManagerProtocol

    public init(
        emailFormatUseCase: some EmailFormatUseCaseProtocol,
        externalLinkOpener: some ExternalLinkOpening,
        appLoadingManager: some AppLoadingStateManagerProtocol
    ) {
        self.emailFormatUseCase = emailFormatUseCase
        self.externalLinkOpener = externalLinkOpener
        self.appLoadingManager = appLoadingManager
    }

    public func presentMailCompose() async {
        appLoadingManager.startLoading()
        let email = await emailFormatUseCase.createEmailFormat()
        guard let url = email.mailToURL else { return }

        externalLinkOpener.openExternalLink(with: url)
        appLoadingManager.stopLoading()
    }
}
