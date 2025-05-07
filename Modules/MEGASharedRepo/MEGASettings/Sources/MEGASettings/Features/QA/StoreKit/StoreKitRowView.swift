// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import SwiftUI

public struct StoreKitRowView: View {
    public init() {}

    public var body: some View {
        NavigationLink {
            ScrollView {
                VStack(spacing: .zero) {
                    ManageStoreKitSubsRowView()
                    ShareReceiptRowView()
                    StoreKitVersionToggleView()
                    SimulateStoreErrorRowView()
                    SimulateSDKPurchaseErrorRowView()
                    SimulateAppStorePriceChangeRowView()
                }
                .navigationTitle("In-app Purchase Settings")
            }
        } label: {
            MEGAList(title: "In-app Purchase Settings")
                .borderEdges(.vertical)
                .trailingChevron()
                .footerText("""
                Open this to access all settings related to in-app purchases.
                """)
                .contentShape(Rectangle())
        }
    }
}
