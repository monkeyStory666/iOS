// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAInfrastructure
import MEGALogger
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import MessageUI

public final class DebugLogsScreenViewModel: ViewModel<DebugLogsScreenViewModel.Route> {
    public enum Route {
        case dismissed
    }

    @ViewProperty public var toggleState: MEGAToggle.State
    @ViewProperty public var alertToPresent: AlertModel?

    /// This property is to attach email through native mail, if not supported
    /// use emailPresenter instead
    @ViewProperty public var emailToCompose: EmailEntity?

    private let debugModeUseCase: any DebugModeUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private let supportNativeMail: () -> Bool
    private let emailFormatUseCase: (any EmailFormatUseCaseProtocol)?
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    /// This email presenter is to present the default email app when
    /// native mail app is not supported. However, this will not attach
    /// any debug logs because of tech limitation
    private let emailPresenter: (any EmailPresenting)?

    public init(
        debugModeUseCase: DebugModeUseCaseProtocol = DependencyInjection.debugModeUseCase,
        snackbarDisplayer: SnackbarDisplaying = DependencyInjection.snackbarDisplayer,
        supportNativeMail: @escaping () -> Bool = { MFMailComposeViewController.canSendMail() },
        emailFormatUseCase: EmailFormatUseCaseProtocol? = DependencyInjection.emailFormatUseCase,
        emailPresenter: EmailPresenting? = DependencyInjection.emailPresenter,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)? = DependencyInjection.analyticsTracker
    ) {
        self.debugModeUseCase = debugModeUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.supportNativeMail = supportNativeMail
        self.emailFormatUseCase = emailFormatUseCase
        self.emailPresenter = emailPresenter
        self.analyticsTracker = analyticsTracker
        self.toggleState = debugModeUseCase.isDebugModeEnabled ? .on : .off
        super.init()
    }

    public var shouldShowContactSupport: Bool {
        toggleState == .on
    }

    public var shouldShowViewLogs: Bool {
        toggleState == .on
    }

    public var shouldShowDisclaimer: Bool {
        toggleState == .on
    }

    public var shouldShowExportLogs: Bool {
        toggleState == .on
    }

    public func onAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .debugLogsScreenView)
        observe {
            debugModeUseCase.observeDebugMode().sink { [weak self] isEnabled in
                self?.refreshToggleState(isEnabled)
            }
        }
    }

    public func didTapDismiss() {
        routeTo(.dismissed)
    }

    public func didTapToggle(_ currentState: MEGAToggle.State) {
        if currentState.isOn {
            presentDisableConfirmationAlert()
        } else {
            presentEnableConfirmationAlert()
        }
    }

    public func didTapContactSupport() async {
        analyticsTracker?.trackAnalyticsEvent(with: .submitDebugLogsButtonPressed)
        if supportNativeMail() {
            presentContactSupportAlert()
        } else {
            await emailPresenter?.presentMailCompose()
        }
    }

    private func presentEnableConfirmationAlert() {
        alertToPresent = .init(
            title: SharedStrings.Localizable.DebugLogs.Settings.Enable.Alert.title,
            message: SharedStrings.Localizable.DebugLogs.Settings.Enable.Alert.message,
            buttons: [
                .init(SharedStrings.Localizable.cancel, role: .cancel),
                .init(SharedStrings.Localizable.confirm) { [weak self] in
                    self?.didConfirmAlert()
                }
            ]
        )
    }

    private func presentDisableConfirmationAlert() {
        alertToPresent = .init(
            title: SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.title,
            message: SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.message,
            buttons: [
                .init(SharedStrings.Localizable.cancel, role: .cancel),
                .init(SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.action) { [weak self] in
                    self?.didConfirmAlert()
                }
            ]
        )
    }

    private func presentContactSupportAlert() {
        alertToPresent = .init(
            title: SharedStrings.Localizable.DebugLogs.Settings.ContactSupport.Alert.title,
            message: SharedStrings.Localizable.DebugLogs.Settings.ContactSupport.Alert.message,
            buttons: [
                .init(SharedStrings.Localizable.cancel, role: .cancel),
                .init(SharedStrings.Localizable.continue) { [weak self] in
                    await self?.presentMailWithAttachments()
                }
            ]
        )
    }

    private func presentMailWithAttachments() async {
        emailToCompose = await emailFormatUseCase?.createEmailFormat()
    }

    private func didConfirmAlert() {
        debugModeUseCase.toggleDebugMode()
    }

    private func refreshToggleState(_ isEnabled: Bool) {
        let currentState = toggleState
        toggleState = isEnabled ? .on : .off
        switch (isEnabled, currentState) {
        case (true, .off):
            analyticsTracker?.trackAnalyticsEvent(with: .debugLogsEnabled)
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.DebugLogs.Settings.Snackbar.enabled
            ))
        case (false, .on):
            analyticsTracker?.trackAnalyticsEvent(with: .debugLogsDisabled)
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.DebugLogs.Settings.Snackbar.disabled
            ))
        default: break
        }
    }
}
