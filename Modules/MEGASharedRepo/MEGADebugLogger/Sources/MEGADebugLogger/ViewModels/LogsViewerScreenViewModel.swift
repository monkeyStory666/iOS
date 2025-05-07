// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGALogger
import MEGAPresentation
import SwiftUI

struct LogStringWrapper: Identifiable {
    let id = UUID()
    let logs: [NSAttributedString]
}

public final class LogsViewerScreenViewModel: NoRouteViewModel {
    @ViewProperty var logWrapper: LogStringWrapper?

    private let loggingUseCase: any LoggingUseCaseProtocol
    private let stringFromLink: (URL) -> String?

    public init(
        loggingUseCase: some LoggingUseCaseProtocol = DependencyInjection.loggingUseCase,
        stringFromLink: @escaping (URL) -> String?
    ) {
        self.loggingUseCase = loggingUseCase
        self.stringFromLink = stringFromLink
    }

    public func didTapButton() {
        guard let logFilesLink = (try? loggingUseCase.logFiles()) else { return }

        var logsToView: [NSAttributedString] = []
        for link in logFilesLink {
            if let fileContents = stringFromLink(link) {
                logsToView.append(makeAttributedTextWithLineNumbers(fileContents))
            }
        }
        if !logsToView.isEmpty {
            logWrapper = LogStringWrapper(logs: logsToView)
        }
    }

    public func didTapDismissViewer() {
        logWrapper = nil
    }

    private func makeAttributedTextWithLineNumbers(_ content: String) -> NSAttributedString {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        let attributedString = NSMutableAttributedString()

        for (index, line) in lines.enumerated() {
            let lineNumber = "\(index + 1)\t"
            let lineText = "\(line)\n"

            let lineNumberAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: TokenColors.Text.primary,
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            ]

            let lineAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: TokenColors.Text.secondary,
                .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            ]

            attributedString.append(NSAttributedString(string: lineNumber, attributes: lineNumberAttributes))
            attributedString.append(NSAttributedString(string: lineText, attributes: lineAttributes))
        }

        return attributedString
    }
}
