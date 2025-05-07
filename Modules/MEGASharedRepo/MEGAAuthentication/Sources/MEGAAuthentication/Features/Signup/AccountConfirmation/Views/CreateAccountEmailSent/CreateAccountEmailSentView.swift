// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGAConnectivity
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct CreateAccountEmailSentView: View {
    @StateObject private var viewModel: CreateAccountEmailSentViewModel

    init(viewModel: @autoclosure @escaping () -> CreateAccountEmailSentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        EmailSentView(viewModel: viewModel.emailSentViewModel)
            .navigationLink(
                unwrap: $viewModel.route.case(/CreateAccountEmailSentViewModel.Route.changeEmail)
            ) { changeEmailViewModel in
                ChangeEmailView(viewModel: changeEmailViewModel.wrappedValue)
                    .navigationTitle(SharedStrings.Localizable.EmailConfirmation.ChangeEmail.navigationTitle)
            }
            .alert(unwrapModel: $viewModel.alertToPresent)
            .task {
                await viewModel.onViewAppear()
            }
    }
}

struct EmailConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationViewStack {
            CreateAccountEmailSentView(
                viewModel: DependencyInjection.emailConfirmationViewModel(
                    with: .init(name: "Test", email: "test@email.com", password: "")
                )
            )
        }
    }
}
