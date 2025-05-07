// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAAccountManagement
import MEGAConnectivity
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class SettingsListLogOutRowViewModel: NoRouteViewModel, ListRowViewModel {
    var title: String = SharedStrings.Localizable.logOut

    public var rowView: some View {
        SettingsListLogOutRowView(viewModel: self)
    }

    private let offboardingUseCase: any OffboardingUseCaseProtocol

    public init(offboardingUseCase: some OffboardingUseCaseProtocol) {
        self.offboardingUseCase = offboardingUseCase

    }

    public func didTapRow() async {
        await offboardingUseCase.activeLogout()
    }
}
