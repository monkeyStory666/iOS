// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGALogger
import MEGAPresentation
import SwiftUI

struct LogFileWrapper: Identifiable {
    var id = UUID()
    var urls: [URL]
}

public final class ShareLogsViewModel: NoRouteViewModel {
    @ViewProperty var logsToShare: LogFileWrapper?
    @ViewProperty var logFilesLink: [URL] = []

    var loggingUseCase: any LoggingUseCaseProtocol

    public init(
        loggingUseCase: some LoggingUseCaseProtocol = DependencyInjection.loggingUseCase
    ) {
        self.loggingUseCase = loggingUseCase
    }

    func onAppear() {
        logFilesLink = (try? loggingUseCase.logFiles()) ?? []
    }

    func didTapButton() {
        logsToShare = LogFileWrapper(urls: logFilesLink)
    }
}
