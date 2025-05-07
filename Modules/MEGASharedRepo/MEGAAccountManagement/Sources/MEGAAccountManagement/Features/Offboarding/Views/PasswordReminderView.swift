// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct PasswordReminderView: View {
    @StateObject private var viewModel: PasswordReminderViewModel

    init(
        viewModel: @autoclosure @escaping ()
            -> PasswordReminderViewModel = PasswordReminderViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        switch viewModel.route {
        case .presentRecoveryKey:
            contentWithoutNavigation
                .navigationLink(
                    unwrap: $viewModel.route
                        .case(/PasswordReminderViewModel.Route.presentRecoveryKey)
                ) { $viewModel in
                    RecoveryKeyView(viewModel: $viewModel.wrappedValue)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .navigationTitle(SharedStrings.Localizable.Offboarding.RecoveryKey.title)
                }
        case .presentTestPassword:
            contentWithoutNavigation
                .navigationLink(
                    unwrap: $viewModel.route
                        .case(/PasswordReminderViewModel.Route.presentTestPassword)
                ) { $viewModel in
                    TestPasswordView(viewModel: $viewModel.wrappedValue)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .navigationTitle(SharedStrings.Localizable.TestPassword.buttonTitle)
                }
        default:
            contentWithoutNavigation
        }
    }

    var contentWithoutNavigation: some View {
        VStack(spacing: TokenSpacing._5) {
            VStack(spacing: TokenSpacing._5) {
                Image("OffboardingPasswordReminder", bundle: .module)
                    .resizable()
                    .frame(width: 120, height: 120, alignment: .center)
                Text(SharedStrings.Localizable.Offboarding.PasswordReminder.title)
                    .font(.title2.bold())
                subtitleLabel
                exportRecoveryKeyButton
                testPasswordButton
                dontShowAgainCheckmark
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear { viewModel.onAppear() }
        .padding(.horizontal, TokenSpacing._5)
    }

    var subtitleLabel: some View {
        Text(.init(
            SharedStrings.Localizable.Offboarding.PasswordReminder
                .subtitle.assignLink(Constants.Link.recoveryKeyLearnMore)
        ))
        .multilineTextAlignment(.center)
        .font(.callout)
        .foregroundColor(TokenColors.Text.secondary.swiftUI)
        .tint(TokenColors.Link.primary.swiftUI)
    }

    var exportRecoveryKeyButton: some View {
        MEGAButton(SharedStrings.Localizable.Offboarding.ExportRecoveryKey.buttonTitle) {
            viewModel.didTapRecoveryKey()
        }
    }

    var testPasswordButton: some View {
        MEGAButton(
            SharedStrings.Localizable.Offboarding.TestPassword.buttonTitle,
            type: .secondary
        ) {
            viewModel.didTapTestPassword()
        }
    }

    var dontShowAgainCheckmark: some View {
        HStack(spacing: TokenSpacing._7) {
            MEGAChecklist(isChecked: $viewModel.doNotShowThisAgainIsChecked)
            Text(SharedStrings.Localizable.Offboarding.DontShowThisAgain.checkmarkLabel)
                .font(.footnote)
                .foregroundColor(TokenColors.Text.primary.swiftUI)
        }
    }
}

struct PasswordReminderView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordReminderView(viewModel: PasswordReminderViewModel())
    }
}
