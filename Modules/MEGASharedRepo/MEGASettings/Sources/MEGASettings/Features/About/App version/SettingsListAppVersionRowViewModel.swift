// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGADebugLogger
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public final class SettingsListAppVersionRowViewModel: NoRouteViewModel, ListRowViewModel {
    public var title: String {
        let version = isDebugModeEnabled ? "\(appVersion) (\(buildNumber))" : appVersion
        return SharedStrings.Localizable.Settings.About.version(version)
    }

    public var shouldShowShareLink: Bool { isDebugModeEnabled && !disableDebugMode }

    @ViewProperty var alertToPresent: AlertModel?

    private let appVersion: String
    private let buildNumber: String
    public let disableDebugMode: Bool

    public var rowView: some View {
        SettingsListAppVersionRowView(viewModel: self)
    }

    public var isDebugModeEnabled: Bool { debugModeUseCase.isDebugModeEnabled }

    public var debugModeUseCase: any DebugModeUseCaseProtocol

    public init(
        appVersion: String = DependencyInjection.appInformation.appVersion,
        buildNumber: String = DependencyInjection.appInformation.buildNumber,
        disableDebugMode: Bool = false,
        debugModeUseCase: some DebugModeUseCaseProtocol = MEGADebugLogger.DependencyInjection.debugModeUseCase
    ) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.disableDebugMode = disableDebugMode
        self.debugModeUseCase = debugModeUseCase
        super.init()
    }

    public func didTappedFiveTimes() {
        guard !disableDebugMode else { return }

        presentDebugModeToggle()
    }

    private func presentDebugModeToggle() {
        if isDebugModeEnabled {
            alertToPresent = AlertModel(
                title: SharedStrings.Localizable.DisableDebugMode.title,
                message: SharedStrings.Localizable.DisableDebugMode.message,
                buttons: alertButtons
            )
        } else {
            alertToPresent = AlertModel(
                title: SharedStrings.Localizable.EnableDebugMode.title,
                message: SharedStrings.Localizable.EnableDebugMode.message,
                buttons: alertButtons
            )
        }
    }

    private var alertButtons: [AlertButtonModel] {
        [
            .init(SharedStrings.Localizable.GeneralAction.actionOK) { [weak self] in
                self?.didConfirmAlert()
            },
            .init(SharedStrings.Localizable.cancel, role: .cancel)
        ]
    }

    public func didConfirmAlert() {
        toggleDebugMode()
    }

    private func toggleDebugMode() {
        debugModeUseCase.toggleDebugMode()
        alertToPresent = nil
    }
}
