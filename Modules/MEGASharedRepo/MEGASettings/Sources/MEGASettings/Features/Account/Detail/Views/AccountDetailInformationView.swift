// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGADesignToken
import MEGAUIComponent
import SwiftUI

struct AccountDetailInformationView: View {
    @StateObject private var viewModel: AccountDetailInformationViewModel
    @StateObject private var avatarViewModel: AvatarViewModel

    init(
        viewModel: @autoclosure @escaping () -> AccountDetailInformationViewModel,
        avatarViewModel: @autoclosure @escaping () -> AvatarViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        _avatarViewModel = StateObject(wrappedValue: avatarViewModel())
    }

    var body: some View {
        MEGAList(
            title: viewModel.title,
            subtitle: viewModel.subtitle
        )
        .titleRedacted(length: 10, isActive: viewModel.titleIsRedacted)
        .subtitleRedacted(length: 24, isActive: viewModel.subtitleIsRedacted)
        .replaceLeadingView {
            AvatarView(viewModel: avatarViewModel)
                .frame(width: 56, height: 56, alignment: .center)
        }
        .task { await viewModel.onAppear() }
    }
}
