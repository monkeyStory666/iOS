// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAConnectivity
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class DeleteAccountViewModel: ViewModel<DeleteAccountViewModel.Route>, ListRowViewModel {
    public enum Route {
        case detail(DeleteAccountDetailsViewModel)
    }

    public var rowView: some View {
        DeleteAccountView(viewModel: self)
    }

    private let snackbarDisplayer: SnackbarDisplaying
    private let connectionUseCase: ConnectionUseCaseProtocol
    private let clientDetailsSection: DeleteAccountDetailsSectionViewModel?

    public init(
        snackbarDisplayer: any SnackbarDisplaying = DependencyInjection.snackbarDisplayer,
        connectionUseCase: some ConnectionUseCaseProtocol = DependencyInjection.connectionUseCase,
        clientDetailsSection: DeleteAccountDetailsSectionViewModel? = DependencyInjection.clientDetailsSection
    ) {
        self.snackbarDisplayer = snackbarDisplayer
        self.connectionUseCase = connectionUseCase
        self.clientDetailsSection = clientDetailsSection
    }

    public func onTap() {
        guard connectionUseCase.isConnected else {
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.Settings.AccountDetail.deleteAccountNoInternetAlertTitle
            ))
            return
        }


        if let clientDetailsSection {
            routeTo(.detail(MEGAAccountManagement.DependencyInjection.makeDeleteAccountDetailsViewModel(
                with: [clientDetailsSection] + DeleteAccountDetailsSectionViewModel.commonSections
            )))

        } else {
            routeTo(.detail(MEGAAccountManagement.DependencyInjection.makeDeleteAccountDetailsViewModel(
                with: DeleteAccountDetailsSectionViewModel.commonSections
            )))

        }
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .detail(let detailsViewModel):
            bind(detailsViewModel) { [weak self] in
                $0.$route.sink { route in
                    switch route {
                    case .dismissed:
                        self?.routeTo(nil)
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
    }
}

extension DeleteAccountViewModel.Route {
    var isShowingDetails: Bool {
        if case .detail = self {
            return true
        } else {
            return false
        }
    }
}
