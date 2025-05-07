// Copyright © 2025 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI
import UIKit

public struct LogsViewerScreen: View {
    @StateObject private var viewModel: LogsViewerScreenViewModel

    public init(viewModel: @autoclosure @escaping () -> LogsViewerScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        MEGAButton(
            SharedStrings.Localizable.DebugLogs.Settings.Buttons.viewLog,
            type: .secondary,
            action: viewModel.didTapButton
        )
        .dynamicSheet(unwrap: $viewModel.logWrapper) { logStringWrapper in
            NavigationViewStack {
                TabView {
                    ForEach(logStringWrapper.wrappedValue.logs, id: \.self) { log in
                        LogTextView(log: log)
                            .ignoresSafeArea()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(SharedStrings.Localizable.DebugLogs.Settings.Buttons.viewLog)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(
                            action: { viewModel.didTapDismissViewer() },
                            label: { XmarkCloseButton() }
                        )
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        ShareLogsView(viewModel: DependencyInjection.sharedLogsViewModel) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(TokenColors.Icon.primary.swiftUI)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

public struct LogTextView: UIViewRepresentable {
    public let log: NSAttributedString

    public init(log: NSAttributedString) {
        self.log = log
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = TokenColors.Background.page
        textView.isScrollEnabled = true
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = log
    }
}
