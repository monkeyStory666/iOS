// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class SettingsListSupportRowViewModel:
    ViewModel<SettingsListSupportRowViewModel.Route>,
    ListRowViewModel {
    public enum Route {
        case presentMailCompose
    }

    public var title: String = SharedStrings.Localizable.Settings.Help.contactSupport
    public let icon = Image("MailMediumLightOutline", bundle: .module)

    public var rowView: some View {
        SettingsListSupportRowView(viewModel: self)
    }

    private var emailPresenter: (any EmailPresenting)?

    public init(
        emailPresenter: (any EmailPresenting)? = DependencyInjection.supportEmailPresenter
    ) {
        self.emailPresenter = emailPresenter
    }

    public func didTapRow() async {
        await emailPresenter?.presentMailCompose()
    }
}
