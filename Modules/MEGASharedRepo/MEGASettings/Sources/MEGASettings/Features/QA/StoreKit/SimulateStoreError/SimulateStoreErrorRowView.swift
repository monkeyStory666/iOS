
// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAStoreKit
import StoreKit
import SwiftUI

public struct SimulateStoreErrorRowView: View {
    @StateObject private var viewModel: SimulateStoreErrorRowViewModel

    public init(
        viewModel: @autoclosure @escaping () -> SimulateStoreErrorRowViewModel = SimulateStoreErrorRowViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        MEGAList(contentBorderEdges: .vertical) {
            Picker(
                "Simulate Store Errors",
                selection: Binding(get: {
                    viewModel.storeError
                }, set: {
                    viewModel.select($0)
                })
            ) {
                ForEach(viewModel.errorOptions, id: \.self) { item in
                    Text(item?.qaDescription ?? "Disabled")
                }
            }
            .tint(TokenColors.Text.primary.swiftUI)
            .navigationLinkPickerStyle()
            .padding(.vertical, 16)
        }
        .trailingChevron()
        .footerText("""
        This option is to simulate StoreKit errors when trying to subscribe to a StoreKit plan
        """)
    }
}

extension StoreError {
    var qaDescription: String {
        switch self {
        case .system:
            "System Error"
        case .notAvailableInRegion:
            "Not Available In Region"
        case .invalid:
            "Invalid Error"
        case .generic:
            "Generic Error"
        case .offerInvalid:
            "Invalid Offer Error"
        case .unverifiedTransaction:
            "Unverified Transaction Error"
        case .networkError:
            "Network Error"
        case .userCancelled:
            "User Cancelled"
        case .userCannotMakePayments:
            "User Cannot Make Payments"
        case .pending:
            "Purchase Pending"
        }
    }
}
