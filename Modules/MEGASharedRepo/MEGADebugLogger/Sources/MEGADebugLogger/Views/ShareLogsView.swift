// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAUIComponent
import MEGASharedRepoL10n
import SwiftUI

public struct ShareLogsView<Label: View>: View {
    @StateObject private var viewModel: ShareLogsViewModel

    private let label: () -> Label

    public init(
        viewModel: @autoclosure @escaping () -> ShareLogsViewModel,
        @ViewBuilder label: @escaping () -> Label
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.label = label
    }

    public var body: some View {
        if #available(iOS 16, *) {
            ShareLink(items: viewModel.logFilesLink) {
                label()
            }
            .onAppear {
                // Add 0.1s delay before loading the logFilesLink to make sure
                // logFilesLink is loaded after ShareLogsView is rendered
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.onAppear()
                }
            }
        } else {
            Button {
                viewModel.didTapButton()
            } label: {
                label()
            }
            #if targetEnvironment(macCatalyst)
            .fullScreenCover(unwrap: $viewModel.logsToShare) { logsToShare in
                ZStack(alignment: .center) {
                    ShareSheetView(
                        itemsToShare: logsToShare.urls.wrappedValue,
                        didDismiss: { _ in }
                    )
                    ProgressView()
                }
            }
            #else
            .sheet(unwrap: $viewModel.logsToShare) { logsToShare in
                ShareSheetView(
                    itemsToShare: logsToShare.urls.wrappedValue,
                    didDismiss: { _ in }
                )
            }
            #endif
        }
    }
}

public extension ShareLogsView {
    init(
        viewModel: @autoclosure @escaping () -> ShareLogsViewModel
    ) where Label == MEGAList<
        MEGAListTextContentView,
        MEGAListImageAccessoryView,
        EmptyView,
        EmptyView,
        EmptyView
    > {
        self.init(viewModel: viewModel()) {
            MEGAList(title: SharedStrings.Localizable.DebugMode.shareLogs)
                .leadingImage(icon: Image(systemName: "square.and.arrow.up"))
        }
    }
}
