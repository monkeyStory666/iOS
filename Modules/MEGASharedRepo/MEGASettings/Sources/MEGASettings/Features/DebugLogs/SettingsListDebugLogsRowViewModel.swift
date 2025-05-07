// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADebugLogger
import MEGAPresentation
import SwiftUI

public final class SettingsListDebugLogsRowViewModel:
    ViewModel<SettingsListDebugLogsRowViewModel.Route>,
    ListRowViewModel {
    public enum Route {
        case presentSettings(DebugLogsScreenViewModel)
    }

    public var rowView: some View {
        SettingsListDebugLogsRowView(viewModel: self)
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .presentSettings(let debugLogsViewModel):
            bind(debugLogsViewModel) { [weak self] in
                $0.$route.sink { route in
                    switch route {
                    case .dismissed:
                        self?.routeTo(nil)
                    default: break
                    }
                }
            }
        default: break
        }
    }

    public func didTapRow() {
        routeTo(.presentSettings(DebugLogsScreenViewModel()))
    }
}
