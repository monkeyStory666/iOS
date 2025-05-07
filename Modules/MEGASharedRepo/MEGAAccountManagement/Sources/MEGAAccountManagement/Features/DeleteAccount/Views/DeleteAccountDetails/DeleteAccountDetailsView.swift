// Copyright © 2024 MEGA Limited. All rights reserved.

import CasePaths
import MEGAAuthentication
import MEGAConnectivity
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import MEGADesignToken
import SwiftUI

public struct DeleteAccountDetailsView: View {
    @StateObject private var viewModel: DeleteAccountDetailsViewModel

    public init(viewModel: @autoclosure @escaping () -> DeleteAccountDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationViewStack {
            scrollView
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: viewModel.didTapClose) {
                            XmarkCloseButton()
                        }
                    }
                }
                .navigationLink(
                    unwrap: $viewModel.route.case(/DeleteAccountDetailsViewModel.Route.twoFactorAuthentication)
                ) { $viewModel in
                    TwoFactorAuthenticationView(viewModel: $viewModel.wrappedValue)
                }
                .navigationLink(
                    unwrap: $viewModel.route.case(/DeleteAccountDetailsViewModel.Route.emailSent)
                ) { emailSentViewModel in
                    DeleteAccountEmailSentView(viewModel: emailSentViewModel.wrappedValue)
                }
        }
        .noInternetViewModifier()
        .task {
            try? await viewModel.onAppear()
        }
    }

    private var scrollView: some View {
        ScrollView {
            scrollContentView
                .padding(.horizontal)
                .padding(.top, TokenSpacing._5)
        }
    }

    private var scrollContentView: some View {
        VStack(spacing: TokenSpacing._9) {
            VStack (alignment: .leading, spacing: TokenSpacing._7) {
                titleView
                sectionsView
            }

            buttonsView
        }
    }

    private var titleView: some View {
        Text(SharedStrings.Localizable.DeleteAccount.Details.headerTitle)
            .font(.title2.bold())
    }

    private var sectionsView: some View {
        ForEach(viewModel.sections) { section in
            DeleteAccountDetailsSectionView(section: section)
        }
    }

    private var buttonsView: some View {
        VStack {
            MEGAButton(
                SharedStrings.Localizable.DeleteAccount.Details.continueButtonTitle,
                state: viewModel.buttonState
            ) {
                Task {
                    await viewModel.didTapContinue()
                }
            }

            MEGAButton(
                SharedStrings.Localizable.DeleteAccount.Details.dontDeleteAccountButtonTitle,
                type: .textOnly
            ) {
                viewModel.didTapDontDelete()
            }
            .padding(.bottom, TokenSpacing._7)
        }
    }
}

#Preview {
    DeleteAccountDetailsView(
        viewModel: DeleteAccountDetailsViewModel(
            sections: DeleteAccountDetailsSectionViewModel.commonSections
        )
    )
}
