// Copyright © 2024 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAccountManagement
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct DeleteAccountView: View {
    @StateObject private var viewModel: DeleteAccountViewModel

    init(
        viewModel: @autoclosure @escaping () -> DeleteAccountViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        MEGAButton(
            SharedStrings.Localizable.Settings.AccountDetail.deleteAccount,
            type: .textOnly
        ) {
            viewModel.onTap()
        }
        .dynamicSheet(
            unwrap: $viewModel.route
                .case(/DeleteAccountViewModel.Route.detail)
        ) { deleteAccountDetailsViewModel in
            DeleteAccountDetailsView(viewModel: deleteAccountDetailsViewModel.wrappedValue)
        }
    }
}
