// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct TwoFactorAuthenticationView: View {
    @StateObject public var viewModel: TwoFactorAuthenticationViewModel

    public init(
        viewModel: @autoclosure @escaping () -> TwoFactorAuthenticationViewModel = DependencyInjection.twoFactorAuthenticationViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        ZStack {
            Divider()
            .foregroundColor(TokenColors.Border.subtle.swiftUI)
            .frame(idealHeight: 0.33, maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: TokenSpacing._7) {
                Text(SharedStrings.Localizable.TwoFactorAuthentication.message)
                    .font(.callout)
                    .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: TokenSpacing._2) {
                    PasscodeView(viewModel: viewModel)
                    if viewModel.state == .error {
                        ImageLabel(error: SharedStrings.Localizable.TwoFactorAuthentication.Incorrect.message)
                    }
                }
                Link(destination: Constants.Link.recovery) {
                    Text(SharedStrings.Localizable.TwoFactorAuthentication.LostDevice.buttonTitle)
                        .font(.callout)
                        .foregroundStyle(TokenColors.Link.primary.swiftUI)
                }
            }
            .padding(TokenSpacing._5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .if(viewModel.shouldLimitMaxWidth) {
                $0.frame(maxWidth: 390)
            }
            .if(!viewModel.shouldLimitMaxWidth) {
                $0.maxWidthForWideScreen()
            }

            if viewModel.showLoading {
                LoadingScreenView()
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                backButton
            }
        }
        .pageBackground(alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(
            SharedStrings.Localizable.TwoFactorAuthentication.navTitle
        )
        .onAppear {
            viewModel.onViewAppear()
        }
    }

    private var backButton: some View {
        Button(action: viewModel.didTapBackButton) {
            Image(systemName: "chevron.backward")
                .frame(width: 24, height: 24)
                .foregroundStyle(TokenColors.Icon.primary.swiftUI)
        }
    }
}

private struct PasscodeView: View {
    @ObservedObject var viewModel: TwoFactorAuthenticationViewModel
    @FocusState var hasFocus: Bool

    var body: some View {
        ZStack {
            DigitsView(passcode: viewModel.passcode, state: digitsViewState())
            InvisibleTextField(
                disabled: $viewModel.disableEditing,
                text: $viewModel.passcodeText,
                hasFocus: $hasFocus
            ) { updatedText in
                viewModel.updatePasscode(withText: updatedText)
            }
        }
        .onChange(of: hasFocus) { viewModel.showKeyboard = $0 }
        .onChange(of: viewModel.showKeyboard) { hasFocus = $0 }
    }

    private func digitsViewState() -> DigitsView.State {
        switch viewModel.state {
        case .normal:
            if hasFocus {
                return .editing(index: viewModel.passcode.count)
            } else {
                return .normal
            }
        case .success:
            return .success
        case .error:
            if hasFocus {
                return .errorEditing(index: viewModel.passcode.count)
            } else {
                return .error
            }
        }
    }
}

struct TwoFactorAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationViewStack {
            TwoFactorAuthenticationView(
                viewModel: DependencyInjection.twoFactorAuthenticationViewModel
            )
        }
    }
}
