// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import MEGASharedRepoL10n
import MEGAUIComponent

public class CreateAccountEmailSentConfiguration: EmailSentConfigurable {
    public var headerTitle: String { SharedStrings.Localizable.EmailConfirmation.title }
    public var primaryButtonTitle: String {  SharedStrings.Localizable.EmailConfirmation.Resend.buttonTitle }
    public var secondaryButtonTitle: String? { SharedStrings.Localizable.EmailConfirmation.ChangeEmail.buttonTitle }

    public var descriptionTextWithEmail: DisplayTextWithEmail {
        .init(
            text: SharedStrings.Localizable.EmailConfirmation.message(information.email),
            email: information.email,
            displayOption: .highlight
        )
    }

    public var primaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? {
        resendButtonStatePublisher.eraseToAnyPublisher()
    }

    public var secondaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? {
        changeEmailButtonStatePublisher.eraseToAnyPublisher()
    }

    public var showLoadingPublisher: AnyPublisher<Bool, Never>? {
        showLoadingScreenPassthroughSubject.eraseToAnyPublisher()
    }

    public var descriptionTextWithEmailUpdatePublisher: AnyPublisher<DisplayTextWithEmail, Never>? {
        descriptionTextWithEmailUpdatePassthroughSubject.eraseToAnyPublisher()
    }

    private let resendButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>
    private let changeEmailButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>
    private let showLoadingScreenPassthroughSubject: PassthroughSubject<Bool, Never>
    private let descriptionTextWithEmailUpdatePassthroughSubject = PassthroughSubject<DisplayTextWithEmail, Never>()
    private var information: NewAccountInformationEntity
    private var informationUpdateCancellable: AnyCancellable?

    public init(
        information: NewAccountInformationEntity,
        resendButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>,
        changeEmailButtonStatePublisher: PassthroughSubject<MEGAButtonStyle.State, Never>,
        showLoadingScreenPassthroughSubject: PassthroughSubject<Bool, Never>,
        informationUpdatePassthroughSubject: PassthroughSubject<NewAccountInformationEntity, Never>
    ) {
        self.information = information
        self.resendButtonStatePublisher = resendButtonStatePublisher
        self.changeEmailButtonStatePublisher = changeEmailButtonStatePublisher
        self.showLoadingScreenPassthroughSubject = showLoadingScreenPassthroughSubject
        listen(to: informationUpdatePassthroughSubject)
    }

    private func listen(to informationUpdatePassthroughSubject: PassthroughSubject<NewAccountInformationEntity, Never>) {
        informationUpdateCancellable = informationUpdatePassthroughSubject.sink { [weak self] updatedInformation in
            guard let self else { return }
            information = updatedInformation
            descriptionTextWithEmailUpdatePassthroughSubject.send(descriptionTextWithEmail)
        }
    }
}
