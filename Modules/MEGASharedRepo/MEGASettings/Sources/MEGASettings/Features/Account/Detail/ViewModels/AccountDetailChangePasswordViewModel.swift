// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class AccountDetailChangePasswordViewModel:
    ViewModel<AccountDetailChangePasswordViewModel.Route>,
    ListRowViewModel {
    public enum Route {
        case changePassword(ChangePasswordViewModel)
    }

    public var title = SharedStrings.Localizable.Settings.AccountDetail.changePassword

    public var rowView: some View {
        AccountDetailChangePasswordView(viewModel: self)
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .changePassword(let changePasswordViewModel):
            bind(changePasswordViewModel) { [weak self] viewModel in
                viewModel.$route.sink { [weak self] route in
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

    public func didTapRow() {
        routeTo(.changePassword(ChangePasswordViewModel()))
    }
}

extension AccountDetailChangePasswordViewModel.Route {
    var isChangePassword: Bool {
        if case .changePassword = self {
            return true
        } else {
            return false
        }
    }
}
