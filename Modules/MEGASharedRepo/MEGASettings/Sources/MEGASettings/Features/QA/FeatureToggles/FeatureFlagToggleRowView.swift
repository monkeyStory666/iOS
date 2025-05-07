// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public struct FeatureFlagToggleRowView: View {
    @StateObject private var viewModel: FeatureFlagToggleRowViewModel

    public init(
        viewModel: @autoclosure @escaping () -> FeatureFlagToggleRowViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    /// Creates an instance of the FeatureFlagToggleRowView with a given title, footer, and feature flag key.
    /// Uses shared user defaults for persistent feature flag storage.
    ///
    /// - Parameters:
    ///   - title: The title of the row
    ///   - footer: An optional footer text for the row
    ///   - key: The key associated with the feature flag
    public init(_ title: String, footer: String? = nil, key: FeatureFlagKey) {
        self.init(
            viewModel: FeatureFlagToggleRowViewModel(
                title: title,
                footer: footer,
                featureFlagKey: key
            )
        )
    }

    /// Creates an instance of the FeatureFlagToggleRowView with a given title, footer, and feature flag key.
    /// Uses shared user defaults for persistent feature flag storage.
    /// 
    /// - Parameters:
    ///   - title: The title of the row
    ///   - footer: An optional footer text for the row
    ///   - key: The key associated with the feature flag
    public init(title: String, footer: String? = nil, featureFlagKey: FeatureFlagKey) {
        self.init(
            viewModel: FeatureFlagToggleRowViewModel(
                title: title,
                footer: footer,
                featureFlagKey: featureFlagKey
            )
        )
    }

    /// Creates an instance of the FeatureFlagToggleRowView with a given title, footer, and feature flag key.
    /// Uses shared user defaults for persistent feature flag storage.
    ///
    /// - Parameters:
    ///   - title: The title of the row
    ///   - footer: An optional footer text for the row
    ///   - keyRawValue: The raw value for key associated with the feature flag
    public init(_ title: String, footer: String? = nil, keyRawValue: String) {
        self.init(
            viewModel: FeatureFlagToggleRowViewModel(
                title: title,
                footer: footer,
                featureFlagKeyRawValue: keyRawValue
            )
        )
    }

    /// Creates an instance of the FeatureFlagToggleRowView with a given title, footer, and feature flag key.
    /// Uses shared user defaults for persistent feature flag storage.
    ///
    /// - Parameters:
    ///   - title: The title of the row
    ///   - footer: An optional footer text for the row
    ///   - featureFlagKeyRawValue: The raw value for key associated with the feature flag
    public init(title: String, footer: String? = nil, featureFlagKeyRawValue: String) {
        self.init(
            viewModel: FeatureFlagToggleRowViewModel(
                title: title,
                footer: footer,
                featureFlagKeyRawValue: featureFlagKeyRawValue
            )
        )
    }

    public var body: some View {
        MEGAList(title: viewModel.title)
            .borderEdges(.vertical)
            .replaceTrailingView {
                MEGAToggle(
                    state: .init(isOn: viewModel.isEnabled),
                    toggleAction: { _ in viewModel.toggle() }
                )
            }
            .if(viewModel.footer != nil) { view in
                view.footerText(viewModel.footer!)
            }
    }
}
