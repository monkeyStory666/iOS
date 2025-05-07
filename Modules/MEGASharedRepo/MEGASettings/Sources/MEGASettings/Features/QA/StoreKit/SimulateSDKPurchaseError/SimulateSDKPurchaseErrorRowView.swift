// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import SwiftUI

public struct SimulateSDKPurchaseErrorRowView: View {
    public init() {}

    public var body: some View {
        FeatureFlagToggleRowView(
            title: "Simulate SDK Purchase Error",
            footer: """
            Enable this when testing restore purchase to simulate SDK purchase errors subscribing.
            The StoreKit purchase flow will still be successful.
            After successful StoreKit purchase disable this and try restoring the purchase.
            """,
            featureFlagKey: .simulateSDKPurchaseError
        )
    }
}
