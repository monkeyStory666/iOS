// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct AccountDetailRecoveryKeyView: View {
    @StateObject private var viewModel: AccountDetailRecoveryKeyViewModel

    init(
        viewModel: @autoclosure @escaping () -> AccountDetailRecoveryKeyViewModel =
        AccountDetailRecoveryKeyViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: TokenSpacing._6) {
            MEGAButton(
                SharedStrings.Localizable.Settings.AccountDetail.RecoveryKey.exportKey,
                type: .secondary,
                action: viewModel.didTapRow
            )
            .navigationLink(isActive: $viewModel.isPresentingRecoveryKeyView) {
                RecoveryKeyView(viewModel: RecoveryKeyViewModel())
                    .frame(maxHeight: .infinity, alignment: .top)
                    .navigationTitle(
                        SharedStrings.Localizable.Settings.AccountDetail.RecoveryKey.sectionTitle
                    )
            }

            if let recoveryKeyDisclaimer = DependencyInjection.recoveryKeyDisclaimer {
                Text(.init(recoveryKeyDisclaimer.assignLink(Constants.Link.recoveryKeyLearnMore)))
                .font(.system(size: 13))
                .foregroundColor(TokenColors.Text.secondary.swiftUI)
                .tint(TokenColors.Link.primary.swiftUI)
            }
        }
        .padding(.horizontal, TokenSpacing._5)
    }
}
