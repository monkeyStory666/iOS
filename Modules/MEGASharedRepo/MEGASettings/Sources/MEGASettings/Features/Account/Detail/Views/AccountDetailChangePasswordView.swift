// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAccountManagement
import MEGAConnectivity
import MEGAPresentation
import MEGAUIComponent
import SwiftUI

struct AccountDetailChangePasswordView: View {
    @StateObject private var viewModel: AccountDetailChangePasswordViewModel

    init(
        viewModel: @autoclosure @escaping () -> AccountDetailChangePasswordViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Button {
            viewModel.didTapRow()
        } label: {
            MEGAList(title: viewModel.title)
                .trailingChevron()
        }
        .dynamicSheet(
            unwrap: $viewModel.route
                .case(/AccountDetailChangePasswordViewModel.Route.changePassword)
        ) { changePasswordViewModel in
            changePasswordView(changePasswordViewModel.wrappedValue)
        }
    }

    private func changePasswordView(
        _ changePasswordViewModel: ChangePasswordViewModel
    ) -> some View {
        NavigationViewStack {
            ChangePasswordView(viewModel: changePasswordViewModel)
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .noInternetViewModifier()
    }
}

struct AccountDetailChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailChangePasswordView(viewModel: .init())
    }
}
