// Copyright © 2025 MEGA Limited. All rights reserved.

import CasePaths
import MEGADebugLogger
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct SettingsListDebugLogsRowView: View {
    @StateObject var viewModel: SettingsListDebugLogsRowViewModel

    public var body: some View {
        Button {
            viewModel.didTapRow()
        } label: {
            MEGAList(title: SharedStrings.Localizable.DebugLogs.Settings.title)
                .leadingImage(icon: Image(.fileSearchMediumThinOutline))
                .trailingChevron()
                .contentShape(Rectangle())
        }
        .dynamicSheet(
            unwrap: $viewModel.route.case(
                /SettingsListDebugLogsRowViewModel.Route.presentSettings
            )
        ) { $viewModel in
            NavigationViewStack {
                DebugLogsScreen(viewModel: $viewModel.wrappedValue)
            }
        }
    }
}
