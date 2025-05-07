// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAnalytics
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent

public final class EmailSentViewModel: ViewModel<EmailSentViewModel.Route> {
    public enum Route {
        case dismissed
        case primaryButtonPressed
        case secondaryButtonPressed
    }

    private let configuration: any EmailSentConfigurable
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let supportEmailPresenter: (any EmailPresenting)?
    private var supportEmail: String { Constants.Email.support }

    var headerTitle: String { configuration.headerTitle }
    var primaryButtonTitle: String { configuration.primaryButtonTitle }
    var secondaryButtonTitle: String? { configuration.secondaryButtonTitle }

    @ViewProperty public var primaryButtonState = MEGAButtonStyle.State.default
    @ViewProperty public var secondaryButtonState = MEGAButtonStyle.State.default
    @ViewProperty public var showLoading = false
    @ViewProperty public var descriptionTextWithEmail: DisplayTextWithEmail

    var supportTextWithEmail: DisplayTextWithEmail {
        .init(
            text: SharedStrings.Localizable.ConfirmationText.Support.message,
            email: supportEmail,
            displayOption: .link {
                Task { [weak self] in
                    guard let self else { return }
                    await sendEmailToSupport()
                }
            }
        )
    }

    public init(
        configuration: some EmailSentConfigurable,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?,
        supportEmailPresenter: (any EmailPresenting)?
    ) {
        self.configuration = configuration
        self.analyticsTracker = analyticsTracker
        self.supportEmailPresenter = supportEmailPresenter
        self.descriptionTextWithEmail = configuration.descriptionTextWithEmail
        super.init()
        listenToEvents()
    }

    public func didTapCloseButton() {
        routeTo(.dismissed)
    }

    public func primaryButtonPressed() {
        analyticsTracker?.trackAnalyticsEvent(
            with: .resendEmailConfirmationButtonPressed
        )
        routeTo(.primaryButtonPressed)
    }

    public func secondaryButtonPressed() {
        routeTo(.secondaryButtonPressed)
    }

    public func sendEmailToSupport() async {
        await supportEmailPresenter?.presentMailCompose()
    }

    // MARK: - Private methods.

    private func listenToEvents() {
        listen(to: configuration.primaryButtonStatePublisher, keyPath: \.primaryButtonState)
        listen(to: configuration.secondaryButtonStatePublisher, keyPath: \.secondaryButtonState)
        listen(to: configuration.showLoadingPublisher, keyPath: \.showLoading)
        listen(to: configuration.descriptionTextWithEmailUpdatePublisher, keyPath: \.descriptionTextWithEmail)
    }

    private func listen<T>(to publisher: AnyPublisher<T, Never>?, keyPath: ReferenceWritableKeyPath<EmailSentViewModel, T>) {
        guard let publisher = publisher else { return }
        observe {
            publisher.sink { [weak self] value in
                guard let self else { return }
                self[keyPath: keyPath] = value
            }
        }
    }
}
