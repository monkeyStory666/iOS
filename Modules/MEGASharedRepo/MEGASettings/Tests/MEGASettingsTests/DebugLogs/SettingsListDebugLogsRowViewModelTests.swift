// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADebugLogger
import MEGASettings
import MEGAPresentation
import Testing

struct SettingsListDebugLogsRowViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.route == nil)
    }

    @Test func didTapRow() {
        let sut = makeSUT()

        sut.didTapRow()

        #expect(sut.route?.isPresentingSettings == true)
    }

    @Test func debugLogsSettingsBindings() {
        let sut = makeSUT()

        let debugLogsViewModel = DebugLogsScreenViewModel()
        sut.routeTo(.presentSettings(debugLogsViewModel))

        debugLogsViewModel.routeTo(.dismissed)
        #expect(sut.route == nil)
    }

    // MARK: - Test Helpers

    private func makeSUT() -> SettingsListDebugLogsRowViewModel {
        SettingsListDebugLogsRowViewModel()
    }
}

extension SettingsListDebugLogsRowViewModel.Route {
    var isPresentingSettings: Bool {
        switch self {
        case .presentSettings: true
        }
    }
}
