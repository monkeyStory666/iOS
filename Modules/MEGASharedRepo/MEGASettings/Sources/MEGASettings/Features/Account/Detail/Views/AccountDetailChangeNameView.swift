// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAccountManagement
import MEGAConnectivity
import MEGAPresentation
import MEGAUIComponent
import SwiftUI

struct AccountDetailChangeNameView: View {
    @StateObject private var viewModel: AccountDetailChangeNameViewModel

    init(
        viewModel: @autoclosure @escaping () -> AccountDetailChangeNameViewModel =
        AccountDetailChangeNameViewModel()
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
                .case(/AccountDetailChangeNameViewModel.Route.changeName)
        ) { changeNameViewModel in
            changeNameView(changeNameViewModel.wrappedValue)
        }
    }

    private func changeNameView(
        _ changeNameViewModel: ChangeNameViewModel
    ) -> some View {
        NavigationViewStack {
            ChangeNameView(viewModel: changeNameViewModel)
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .noInternetViewModifier()
    }
}
