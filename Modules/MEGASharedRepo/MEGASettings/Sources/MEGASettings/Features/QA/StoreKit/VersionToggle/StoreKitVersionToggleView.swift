// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import StoreKit
import SwiftUI

public struct StoreKitVersionToggleView: View {
    @StateObject private var viewModel: StoreKitVersionToggleViewModel

    public init(
        viewModel: @autoclosure @escaping () -> StoreKitVersionToggleViewModel = StoreKitVersionToggleViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        MEGAList(contentBorderEdges: .vertical) {
            Picker(
                "Override StoreKit Version",
                selection: Binding(get: {
                    viewModel.storeVersion
                }, set: {
                    viewModel.select($0)
                })
            ) {
                ForEach(viewModel.options, id: \.self) { version in
                    Text(version?.rawValue ?? "Disabled")
                }
            }
            .tint(TokenColors.Text.primary.swiftUI)
            .navigationLinkPickerStyle()
            .padding(.vertical, 16)
        }
        .trailingChevron()
        .footerText("""
        This is an option to override the version of StoreKit to use for payment.
        It is useful to debug any issues may be caused by a certain version of StoreKit.
        The Disabled option will use the default version of StoreKit in production.
        """)
    }
}
