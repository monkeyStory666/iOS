// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAccountManagement
import MEGAUIComponent
import SwiftUI

struct SettingsListLogOutRowView: View {
    @StateObject private var viewModel: SettingsListLogOutRowViewModel

    init(
        viewModel: @autoclosure @escaping () -> SettingsListLogOutRowViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        MEGAButton(viewModel.title, type: .secondary) {
            Task { await viewModel.didTapRow() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
}
