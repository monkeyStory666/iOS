// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADebugLogger
import MEGADesignToken
import SwiftUI

struct SettingsListAppVersionRowView: View {
    @StateObject private var viewModel: SettingsListAppVersionRowViewModel

    init(
        viewModel: @autoclosure @escaping () -> SettingsListAppVersionRowViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            versionView
            if viewModel.shouldShowShareLink {
                ShareLogsView(viewModel: MEGADebugLogger.DependencyInjection.sharedLogsViewModel)
            }
        }
        .onTapGesture(count: 5) {
            viewModel.didTappedFiveTimes()
        }
        .alert(unwrapModel: $viewModel.alertToPresent)
    }

    private var versionView: some View {
        Text(viewModel.title)
            .font(.footnote)
            .foregroundColor(TokenColors.Text.secondary.swiftUI)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}
