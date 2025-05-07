// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public struct FeatureFlagToggleSectionView<Content: View>: View {
    public var content: () -> Content

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        MEGAList(contentBorderEdges: .vertical) {
            VStack(spacing: .zero) {
                content()
            }
        }
        .headerText("Feature Flags Toggle")
        .footerText("""
        You might need to restart the app after toggling this on
        """)
    }
}

extension FeatureFlagToggleSectionView where Content == FreeTrialRowView {
    public init() {
        self.content = {
            FreeTrialRowView()
        }
    }
}
