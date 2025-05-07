// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct DebugLogsScreen: View {
    @StateObject private var viewModel: DebugLogsScreenViewModel

    public init(viewModel: @autoclosure @escaping () -> DebugLogsScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        DynamicScrollView {
            VStack(spacing: .zero) {
                toggleListRow
                disclaimerBanner
                buttons
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(SharedStrings.Localizable.DebugLogs.Settings.title)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                backButton
            }
        }
        .onAppear { viewModel.onAppear() }
        .alert(unwrapModel: $viewModel.alertToPresent)
        .fullScreenCover(unwrap: $viewModel.emailToCompose) { emailToCompose in
            MailComposeView(email: emailToCompose.wrappedValue)
        }
    }

    private var toggleListRow: some View {
        MEGAList(
            title: SharedStrings.Localizable.DebugLogs.Settings.Toggle.title,
            subtitle: SharedStrings.Localizable.DebugLogs.Settings.Toggle.subtitle
        )
        .replaceTrailingView {
            MEGAToggle(
                state: viewModel.toggleState,
                toggleAction: viewModel.didTapToggle(_:)
            )
        }
    }

    @ViewBuilder var disclaimerBanner: some View {
        if viewModel.shouldShowDisclaimer {
            MEGABanner(
                subtitle: debugLogsDisclaimerString,
                state: .warning
            )
            .padding(TokenSpacing._5)
        }
    }

    private var buttons: some View {
        VStack(spacing: TokenSpacing._5) {
            contactSupportButton
            viewLogsButton
            exportLogsButton
        }
        .padding(TokenSpacing._5)
    }

    @ViewBuilder private var contactSupportButton: some View {
        if viewModel.shouldShowContactSupport {
            MEGAButton(
                SharedStrings.Localizable.DebugLogs.Settings.Buttons.contactSupport,
                icon: Image("ExternalLinkMediumThinOutline", bundle: .module),
                iconAlignment: .trailing
            ) {
                Task { await viewModel.didTapContactSupport() }
            }
        }
    }

    private var debugLogsDisclaimerString: AttributedString {
        let localizedText = SharedStrings.Localizable.DebugLogs.Settings.Toggle.disclaimer

        var attributedString = (
            try? AttributedString(
                markdown: localizedText.assignLink(Constants.Link.privacyPolicyDebugLogs),
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )
        ) ?? AttributedString(localizedText)

        if let range = attributedString.range(
            of: localizedText.getLocalizationSubstring(tag: "L")
        ) {
            attributedString[range].underlineStyle = .single
        }

        return attributedString
    }

    @ViewBuilder private var viewLogsButton: some View {
        if viewModel.shouldShowViewLogs {
            LogsViewerScreen(viewModel: DependencyInjection.logsViewerViewModel)
        }
    }

    @ViewBuilder private var exportLogsButton: some View {
        if viewModel.shouldShowExportLogs {
            ShareLogsView(viewModel: DependencyInjection.sharedLogsViewModel) {
                MEGAButton(
                    SharedStrings.Localizable.DebugLogs.Settings.Buttons.exportLog,
                    type: .textOnly
                )
            }
        }
    }

    private var backButton: some View {
        Button(
            action: { viewModel.didTapDismiss() },
            label: { BackChevron() }
        )
    }
}
