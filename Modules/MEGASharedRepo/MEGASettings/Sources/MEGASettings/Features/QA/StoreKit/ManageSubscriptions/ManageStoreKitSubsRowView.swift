// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAUIComponent
import StoreKit
import SwiftUI

public struct ManageStoreKitSubsRowView: View {
    @State private var isPresentingSubsSheet = false

    public init() {}

    public var body: some View {
        Button {
            isPresentingSubsSheet.toggle()
        } label: {
            MEGAList(title: "Manage App Store Subscriptions")
                .borderEdges(.vertical)
                .footerText("You can cancel ongoing sandbox subscriptions from this page")
                .trailingChevron()
                .contentShape(Rectangle())
        }
        .manageSubscriptionsSheet(isPresented: $isPresentingSubsSheet)
        .buttonStyle(.plain)
    }
}
