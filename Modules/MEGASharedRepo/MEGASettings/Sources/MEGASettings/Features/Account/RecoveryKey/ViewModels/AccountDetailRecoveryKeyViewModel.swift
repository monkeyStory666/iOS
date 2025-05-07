// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAPresentation
import SwiftUI

public final class AccountDetailRecoveryKeyViewModel: NoRouteViewModel, ListRowViewModel {
    @ViewProperty public var isPresentingRecoveryKeyView = false

    public var rowView: some View {
        AccountDetailRecoveryKeyView(viewModel: self)
    }

    public func didTapRow() {
        isPresentingRecoveryKeyView = true
    }
}
