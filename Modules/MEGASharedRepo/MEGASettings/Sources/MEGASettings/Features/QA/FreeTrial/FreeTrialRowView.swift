// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public struct FreeTrialRowView: View {
    @State var flag: TrialEligibilityFlag

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol

    public init(
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        _flag = State(initialValue: featureFlagsUseCase.get(for: .freeTrialEligibility) ?? TrialEligibilityFlag.defaultFlag)
    }

    public var body: some View {
        NavigationLink {
            ScrollView {
                VStack(spacing: .zero) {
                    freeTrialEligibilityPicker
                    FeatureFlagToggleRowView(
                        "Override Trial Eligibility (Apple)",
                        footer: """
                        Enable this toggle when retesting the free trial flow using an Apple account that has already used the free trial, else the normal subscription will be shown instead of the free trial one.

                        Important: Also make sure to use the Reset Eligibility button in the manage app store subscriptions page when retesting free trial so that the purchase sheet will show the free trial correctly.
                        """,
                        key: .overrideFreeTrialEligibility
                    )
                }
                .navigationTitle("Free Trial Settings")
            }
        } label: {
            MEGAList(title: "Free Trial")
                .borderEdges(.vertical)
                .trailingChevron()
                .contentShape(Rectangle())
        }
    }

    private var freeTrialEligibilityPicker: some View {
        MEGAList(contentBorderEdges: .vertical) {
            Picker(
                "Override Trial Eligibility (API)",
                selection: Binding(
                    get: { flag },
                    set: {
                        featureFlagsUseCase.set($0, for: .freeTrialEligibility)
                        flag = $0
                    }
                )
            ) {
                ForEach(TrialEligibilityFlag.allCases, id: \.self) { option in
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
        Use this flag to change the API's Free Trial Eligibility status.
        Default: Use the Free Trial eligibility status from API
        Force Eligible: Force the API Free Trial eligibility to be true
        Force Ineligible: Force the API Free Trial eligibility to be false
        """)
    }
}
