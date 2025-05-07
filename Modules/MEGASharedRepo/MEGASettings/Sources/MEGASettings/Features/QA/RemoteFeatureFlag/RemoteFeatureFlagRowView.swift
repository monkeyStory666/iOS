// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public struct RemoteFeatureFlagRowView: View {
    public enum Option: String, Codable, CaseIterable {
        case useDefault = "Use API Value"
        case forceDisable = "Force Disable All"
        case forceEnable = "Force Enable All"

        public static var defaultFlag: Option {
            .useDefault
        }
    }

    @State var flag: Option

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase) {
        self.featureFlagsUseCase = featureFlagsUseCase
        _flag = State(
            initialValue: featureFlagsUseCase.get(
                for: .toggleRemoteFlag
            ) ?? RemoteFeatureFlagRowView.Option.defaultFlag
        )
    }

    public var body: some View {
        MEGAList(contentBorderEdges: .vertical) {
            Picker(
                "Override Remote Flag",
                selection: Binding(
                    get: { flag },
                    set: {
                        featureFlagsUseCase.set($0, for: .toggleRemoteFlag)
                        flag = $0
                    }
                )
            ) {
                ForEach(RemoteFeatureFlagRowView.Option.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .tint(TokenColors.Text.primary.swiftUI)
            .navigationLinkPickerStyle()
            .padding(.vertical, 16)
        }
        .borderEdges(.vertical)
        .trailingChevron()
        .footerText("""
        You might need to restart the app after changing this value.
        """)
    }
}
