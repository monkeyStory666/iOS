// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import Foundation
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct LoginView: View {
    @StateObject public var viewModel: LoginViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    public init(viewModel: @autoclosure @escaping () -> LoginViewModel = DependencyInjection.loginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationViewStack {
            LoginContentView(viewModel: viewModel)
                .onAppear { viewModel.onAppear() }
                .alert(unwrapModel: $viewModel.alertToPresent)
                .alertButtonTint(color: TokenColors.Text.primary)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: viewModel.didTapDismiss) {
                            XmarkCloseButton()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationLink(
                    unwrap: $viewModel.route.case(/LoginViewModel.Route.twoFactorAuthentication)
                ) { $viewModel in
                    TwoFactorAuthenticationView(viewModel: $viewModel.wrappedValue)
                }
        }
        .noInternetViewModifier()
        .tint(TokenColors.Icon.primary.swiftUI)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: DependencyInjection.loginViewModel)
    }
}
