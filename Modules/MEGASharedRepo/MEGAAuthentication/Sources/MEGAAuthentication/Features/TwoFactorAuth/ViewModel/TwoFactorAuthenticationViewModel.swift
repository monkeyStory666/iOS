// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAPresentation
import MEGASwift

public final class TwoFactorAuthenticationViewModel: ViewModel<
    TwoFactorAuthenticationViewModel
        .Route
> {
    public enum Route: Equatable {
        case verify(_ pin: String)
        case dismissed
    }

    public enum State {
        case normal
        case success
        case error
    }

    @Published public var passcode = Passcode()
    @ViewProperty public var showLoading = false
    @ViewProperty public var disableEditing = false
    @ViewProperty public var state = State.normal
    @ViewProperty public var passcodeText = ""
    @ViewProperty public var showKeyboard = false

    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let sceneType: SceneTypeEntity
    private let delayAfterSuccess: TimeInterval
    
    public var shouldLimitMaxWidth: Bool {
        Constants.isPad
    }

    public init(
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?,
        sceneType: SceneTypeEntity = .normal,
        delayAfterSuccess: TimeInterval = 0
    ) {
        self.analyticsTracker = analyticsTracker
        self.sceneType = sceneType
        self.delayAfterSuccess = delayAfterSuccess
    }

    @MainActor
    public func onViewAppear() {
        trackAnalyticsEvent(.multiFactorAuthScreenView)

        showKeyboard = true
    }

    @MainActor
    public func updatePasscode(withText text: String) {
        refreshPasscodeText(with: Passcode(text: text))
        if passcode.containsMaxValues {
            verify()
        } else if !passcode.isEmpty, state != .normal {
            state = .normal
        }
    }

    @MainActor
    public func didVerifySuccessfully() async {
        trackAnalyticsEvent(.multiFactorAuthSuccessful)
        showLoading = false
        state = .success
        await waitForDelayAfterSuccess()
    }

    @MainActor
    public func didVerifyWithWrongPasscode() {
        trackAnalyticsEvent(.multiFactorAuthFailed)
        refreshPasscodeText(with: Passcode())
        routeTo(nil)
        state = .error
        showLoading = false
        disableEditing = false
        showKeyboard = true
    }

    @MainActor
    public func didTapBackButton() {
        routeTo(.dismissed)
    }

    // MARK: - Private methods

    nonisolated private func trackAnalyticsEvent(_ event: AnalyticsEventEntity) {
        analyticsTracker?.trackAnalyticsEvent(with: event)
    }

    nonisolated private func waitForDelayAfterSuccess() async {
        try? await Task.sleep(nanoseconds: UInt64(delayAfterSuccess) * NSEC_PER_SEC)
    }

    @MainActor
    private func refreshPasscodeText(with newPasscode: Passcode) {
        passcode = newPasscode
        passcodeText = newPasscode.string
    }

    @MainActor
    private func verify() {
        disableEditing = true
        showLoading = true

        switch route {
        case .verify(let pin) where pin == passcode.string:
            break
        default:
            self.route = .verify(passcode.string)
        }
    }
}

public extension TwoFactorAuthenticationViewModel.Route {
    var isVerifying: Bool {
        switch self {
        case .verify: true
        default: false
        }
    }
}
