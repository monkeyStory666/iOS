// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGASharedRepoL10n
import UIKit

public final class NotificationToggleViewModel: NoRouteViewModel {
    public enum State {
        case enabled
        case enabling
        case disabled
        case disabling
    }

    @ViewProperty public var state: State = .disabled

    private let useCase: any NotificationPermissionUseCaseProtocol
    private let settingsOpener: any NotificationSettingsOpening
    private let snackbarDisplayer: any SnackbarDisplaying
    private let requestRegistrationUseCase: any NotificationRequestRegistrationUseCaseProtocol

    public init(
        useCase: some NotificationPermissionUseCaseProtocol,
        settingsOpener: some NotificationSettingsOpening,
        requestRegistrationUseCase: any NotificationRequestRegistrationUseCaseProtocol,
        snackbarDisplayer: some SnackbarDisplaying
    ) {
        self.useCase = useCase
        self.settingsOpener = settingsOpener
        self.requestRegistrationUseCase = requestRegistrationUseCase
        self.snackbarDisplayer = snackbarDisplayer
    }

    @MainActor
    public func onAppear() async {
        await refreshToggleState()
    }

    @MainActor
    public func toggle() async {
        switch state {
        case .enabled:
            await disablingNotifications()
        case .disabled:
            await enablingNotifications()
        case .enabling, .disabling:
            await refreshToggleState()
        }
    }

    private func disablingNotifications() async {
        state = .disabling

        let hasPermission = await useCase.hasPermission()
        guard hasPermission else {
            displaySnackbarIfNeeded(
                previousState: state,
                hasPermission: hasPermission
            )
            state = .disabled
            return
        }

        await navigateToSettings()
    }

    private func enablingNotifications() async {
        state = .enabling

        let hasPermission = await useCase.hasPermission()
        guard !hasPermission else {
            displaySnackbarIfNeeded(
                previousState: state,
                hasPermission: hasPermission
            )
            state = .enabled
            return
        }

        await requestPermission()
    }

    private func requestPermission() async {
        do {
            try await useCase.requestPermission()
            await refreshToggleState()
            if await useCase.hasPermission() {
                await requestRegistrationUseCase.registerForPushNotifications()
            }
        } catch {
            await navigateToSettings()
        }
    }

    private func navigateToSettings() async {
        try? await settingsOpener.open()
    }

    private func refreshToggleState() async {
        let hasPermission = await useCase.hasPermission()
        displaySnackbarIfNeeded(
            previousState: state,
            hasPermission: hasPermission
        )
        updateState(hasPermission: hasPermission)
    }

    private func displaySnackbarIfNeeded(
        previousState: State,
        hasPermission: Bool
    ) {
        switch (previousState, hasPermission) {
        case (.enabling, true):
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.Settings.Notifications.Snackbar.enabled
            ))
        case (.disabling, false):
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.Settings.Notifications.Snackbar.disabled
            ))
        default:
            break
        }
    }

    private func updateState(hasPermission: Bool) {
        state = hasPermission ? .enabled : .disabled
    }
}
