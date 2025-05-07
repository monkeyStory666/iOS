// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGAPresentation
import MEGAUIComponent
import SwiftUI

public struct SettingsListWebRowView: View {
    @StateObject private var viewModel: SettingsListWebRowViewModel

    public init(viewModel: @autoclosure @escaping () -> SettingsListWebRowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        Link(destination: viewModel.url) {
            listRowView
        }
    }

    public var listRowView: some View {
        #if targetEnvironment(macCatalyst)
        MEGAList(title: viewModel.title)
            .trailingImage(icon: Image("ExternalLinkMediumThinOutline", bundle: .module))
            .trailingImageColor(TokenColors.Icon.secondary.swiftUI)
            .if(viewModel.icon != nil) {
                $0.leadingImage(icon: viewModel.icon!)
            }
        #else
        MEGAList(title: viewModel.title)
            .trailingChevron()
            .if(viewModel.icon != nil) {
                $0.leadingImage(icon: viewModel.icon!)
            }
        #endif
    }
}

struct SettingsListWebRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationViewStack {
            SettingsListWebRowView(
                viewModel: SettingsListWebRowViewModel(
                    title: "Preview",
                    url: URL(string: "https://mega.io/")!,
                    icon: Image("ShieldMediumLightOutline", bundle: .module)
                )
            )
        }
    }
}
