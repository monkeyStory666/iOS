// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAConnectivity
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct OffboardingView: View, @unchecked Sendable {
    @StateObject private var viewModel: OffboardingViewModel
    @StateObject private var passwordReminderViewModel: PasswordReminderViewModel

    public init(
        viewModel: @autoclosure @escaping () -> OffboardingViewModel,
        passwordReminderViewModel: @autoclosure @escaping () -> PasswordReminderViewModel =
            PasswordReminderViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        _passwordReminderViewModel = StateObject(wrappedValue: passwordReminderViewModel())
    }

    public var body: some View {
        VStack(spacing: TokenSpacing._5) {
            NavigationViewStack {
                PasswordReminderView(viewModel: passwordReminderViewModel)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(
                        SharedStrings.Localizable.Offboarding.PasswordReminder
                            .navigationTitle
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.didClose()
                            } label: {
                                XmarkCloseButton()
                            }
                        }
                    }
            }
            MEGAButton(
                SharedStrings.Localizable.Offboarding.ProceedToLogout.buttonTitle,
                type: .textOnly
            ) {
                let prelogoutHandler: @Sendable () async
                    -> Void = { [weak passwordReminderViewModel] in
                        await passwordReminderViewModel?.didProceedToLogout()
                    }
                Task { @MainActor [weak viewModel] in
                    await viewModel?.didProceedToLogout(with: prelogoutHandler)
                }
            }
            .padding(TokenSpacing._7)
            .border(width: 0.33, edges: [.top], color: TokenColors.Border.strong.swiftUI)
        }
        .noInternetViewModifier()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environmentObject(viewModel)
    }
}
