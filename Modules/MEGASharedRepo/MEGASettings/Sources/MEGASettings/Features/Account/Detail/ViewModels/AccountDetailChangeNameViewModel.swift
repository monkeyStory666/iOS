// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class AccountDetailChangeNameViewModel:
    ViewModel<AccountDetailChangeNameViewModel.Route>,
    ListRowViewModel {
    public enum Route {
        case changeName(ChangeNameViewModel)
        case nameChanged
    }

    public var title = SharedStrings.Localizable.Settings.AccountDetail.changeName

    public var rowView: some View {
        AccountDetailChangeNameView(viewModel: self)
    }

    public func didTapRow() {
        routeTo(.changeName(ChangeNameViewModel()))
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .changeName(let changeNameViewModel):
            bind(changeNameViewModel) { [weak self] viewModel in
                viewModel.$route.sink { [weak self] route in
                    switch route {
                    case .dismissed:
                        self?.routeTo(nil)
                    case .nameChanged:
                        self?.routeTo(.nameChanged)
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

extension AccountDetailChangeNameViewModel.Route {
    var isChangeName: Bool {
        if case .changeName = self {
            return true
        } else {
            return false
        }
    }

    var isNameChanged: Bool {
        if case .nameChanged = self {
            return true
        } else {
            return false
        }
    }
}
