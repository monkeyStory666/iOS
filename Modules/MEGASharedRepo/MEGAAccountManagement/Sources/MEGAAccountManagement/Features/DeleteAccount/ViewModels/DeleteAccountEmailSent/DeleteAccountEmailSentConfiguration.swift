// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import MEGAAuthentication
import MEGASharedRepoL10n
import MEGAUIComponent

public final class DeleteAccountEmailSentConfiguration: EmailSentConfigurable {
    public var headerTitle: String { SharedStrings.Localizable.EmailConfirmation.DeleteAccount.title }

    public var descriptionTextWithEmail: DisplayTextWithEmail {
        .init(
            text: SharedStrings.Localizable.ConfirmationText.DeleteAccount.message(email),
            email: email,
            displayOption: .highlight
        )
    }

    public var primaryButtonTitle: String { SharedStrings.Localizable.EmailConfirmation.Resend.buttonTitle }

    public var primaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? {
        resendButtonStatePublisher.eraseToAnyPublisher()
    }

    public var secondaryButtonTitle: String? { nil }
    public var secondaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? { nil }

    public var showLoadingPublisher: AnyPublisher<Bool, Never>? { nil }
    public var descriptionTextWithEmailUpdatePublisher: AnyPublisher<MEGAAuthentication.DisplayTextWithEmail, Never>? {
        nil
    }

    private let resendButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>
    private let email: String

    public init(resendButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>, email: String) {
        self.resendButtonStatePublisher = resendButtonStatePublisher
        self.email = email
    }
}
