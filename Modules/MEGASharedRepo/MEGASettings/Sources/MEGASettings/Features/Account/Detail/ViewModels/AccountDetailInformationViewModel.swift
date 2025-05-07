// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAPresentation
import SwiftUI

public final class AccountDetailInformationViewModel: NoRouteViewModel {
    @ViewProperty public var account: AccountEntity?

    public var title: String { account?.fullName ?? "" }
    public var subtitle: String { account?.email ?? "" }

    public var titleIsRedacted: Bool { title.isEmpty }
    public var subtitleIsRedacted: Bool { subtitle.isEmpty }

    private let fetchAccountUseCase: FetchAccountUseCaseProtocol
    private let avatarViewModel: AvatarViewModel

    public init(
        fetchAccountUseCase: FetchAccountUseCaseProtocol = MEGAAccountManagement.DependencyInjection.fetchAccountUseCase,
        avatarViewModel: AvatarViewModel = AvatarViewModel()
    ) {
        self.fetchAccountUseCase = fetchAccountUseCase
        self.avatarViewModel = avatarViewModel
    }

    public func onAppear() async {
        await refresh()
    }

    private func refresh() async {
        guard let account = try? await fetchAccountUseCase.fetchRefreshedAccount() else { return }
        self.account = account
        await avatarViewModel.reloadDefaultAvatarView()
    }
}

extension AccountDetailInformationViewModel: ListRowViewModel {
    public var rowView: some View {
        AccountDetailInformationView(viewModel: self, avatarViewModel: self.avatarViewModel)
    }
}

extension AccountDetailInformationViewModel: Refreshable {
    public func onRefresh() async {
        await refresh()
    }
}
