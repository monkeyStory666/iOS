// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGAUIComponent
import SwiftUI

struct SettingsListSupportRowView: View {
    @StateObject private var viewModel: SettingsListSupportRowViewModel

    init(viewModel: @autoclosure @escaping () -> SettingsListSupportRowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Button {
            Task {
                await viewModel.didTapRow()
            }
        } label: {
            #if targetEnvironment(macCatalyst)
            MEGAList(title: viewModel.title)
                .leadingImage(icon: viewModel.icon)
                .trailingImage(icon: Image("ExternalLinkMediumThinOutline", bundle: .module))
                .trailingImageColor(TokenColors.Icon.secondary.swiftUI)
            #else
            MEGAList(title: viewModel.title)
                .leadingImage(icon: viewModel.icon)
                .trailingChevron()
            #endif
        }
    }
}

struct SettingsListRowEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsListSupportRowView(
            viewModel: .init()
        )
        .disabled(true) // Can't compose email from previews, will result in preview crash
    }
}
