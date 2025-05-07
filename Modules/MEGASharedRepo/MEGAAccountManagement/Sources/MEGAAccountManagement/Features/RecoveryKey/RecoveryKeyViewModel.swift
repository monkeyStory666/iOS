// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent

public final class RecoveryKeyViewModel: NoRouteViewModel {
    @ViewProperty var state: LoadableViewState<String> = .loading
    @ViewProperty var isSavingTextFile: URL?

    var saveButtonState: MEGAButtonStyle.State {
        guard state.isLoaded else { return .disabled }
        guard isSavingTextFile == nil else { return .load }
        return .default
    }

    public var recoveryKeyText: String {
        state.loadedValue ?? "Recovery Key Placeholder"
    }

    public var shouldShowCopyButton: Bool {
        state.isLoaded
    }

    private let snackbarDisplayer: any SnackbarDisplaying
    private let copyToClipboard: any CopyToClipboardProtocol
    private let textFileFromString: any TextFileFromStringProtocol
    private let recoveryKeyUseCase: any RecoveryKeyUseCaseProtocol
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    public init(
        snackbarDisplayer: any SnackbarDisplaying = DependencyInjection.snackbarDisplayer,
        copyToClipboard: some CopyToClipboardProtocol = DependencyInjection.copyToClipboard,
        textFileFromString: some TextFileFromStringProtocol = DependencyInjection.textFileFromString,
        recoveryKeyUseCase: some RecoveryKeyUseCaseProtocol = DependencyInjection.recoveryKeyUseCase,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)? = MEGAAccountManagement.DependencyInjection.analyticsTracker
    ) {
        self.snackbarDisplayer = snackbarDisplayer
        self.copyToClipboard = copyToClipboard
        self.textFileFromString = textFileFromString
        self.recoveryKeyUseCase = recoveryKeyUseCase
        self.analyticsTracker = analyticsTracker
    }

    public func onAppear() {
        analyticsTracker?.trackAnalyticsEvent(with: .recoveryKeyScreenView)
        if let recoveryKey = recoveryKeyUseCase.recoveryKey() {
            state = .loaded(recoveryKey)
        } else {
            state = .failed
        }
    }

    public func didTapCopy() {
        guard let recoveryKey = state.loadedValue else { return }

        recoveryKeyUseCase.keyExported()
        copyToClipboard.copy(text: recoveryKey)
        snackbarDisplayer.display(.init(
            text: SharedStrings.Localizable.ExportRecoveryKey.Snackbar.copied
        ))
    }

    func didTapSaveToDevice() {
        isSavingTextFile = textFileFromString.textFile(from: recoveryKeyText)
    }

    func didDismissSaveSheet(isCompleted: Bool) {
        if isCompleted {
            recoveryKeyUseCase.keyExported()
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.ExportRecoveryKey.Snackbar.saved
            ))
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: URL { self }
}
