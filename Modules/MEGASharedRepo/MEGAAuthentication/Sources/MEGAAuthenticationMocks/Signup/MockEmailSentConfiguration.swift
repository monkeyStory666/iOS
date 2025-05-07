// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Combine
import MEGAUIComponent

public final class MockEmailSentConfiguration: EmailSentConfigurable {
    public var headerTitle: String { "headerTitle" }
    public var primaryButtonTitle: String { "primaryButtonTitle" }
    public var secondaryButtonTitle: String? { "secondaryButtonTitle" }
    public var descriptionTextWithEmail: DisplayTextWithEmail { initialDescriptionTextWithEmail }

    public var primaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? {
        primaryButtonStatePassthroughSubject.eraseToAnyPublisher()
    }

    public var secondaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? {
        secondaryButtonStatePassthroughSubject.eraseToAnyPublisher()
    }

    public var showLoadingPublisher: AnyPublisher<Bool, Never>? {
        showLoadingPassthroughSubject.eraseToAnyPublisher()
    }

    public var descriptionTextWithEmailUpdatePublisher: AnyPublisher<DisplayTextWithEmail, Never>? { 
        descriptionTextWithEmailUpdatePassthroughSubject.eraseToAnyPublisher()
    }

    private let primaryButtonStatePassthroughSubject: PassthroughSubject<MEGAButtonStyle.State, Never>
    private let secondaryButtonStatePassthroughSubject: PassthroughSubject<MEGAButtonStyle.State, Never>
    private let showLoadingPassthroughSubject: PassthroughSubject<Bool, Never>
    private let descriptionTextWithEmailUpdatePassthroughSubject: PassthroughSubject<DisplayTextWithEmail, Never>
    private let initialDescriptionTextWithEmail: DisplayTextWithEmail

    public init(
        primaryButtonStatePassthroughSubject: PassthroughSubject<MEGAButtonStyle.State, Never> 
        = PassthroughSubject<MEGAButtonStyle.State, Never>(),
        secondaryButtonStatePassthroughSubject: PassthroughSubject<MEGAButtonStyle.State, Never>
        = PassthroughSubject<MEGAButtonStyle.State, Never>(),
        showLoadingPassthroughSubject: PassthroughSubject<Bool, Never>
        = PassthroughSubject<Bool, Never>(),
        descriptionTextWithEmailUpdatePassthroughSubject: PassthroughSubject<DisplayTextWithEmail, Never>
        = PassthroughSubject<DisplayTextWithEmail, Never>(),
        initialDescriptionTextWithEmail: DisplayTextWithEmail
        = .init(text: "text", email: "email@email.com", displayOption: .none)
    ) {
        self.primaryButtonStatePassthroughSubject = primaryButtonStatePassthroughSubject
        self.secondaryButtonStatePassthroughSubject = secondaryButtonStatePassthroughSubject
        self.showLoadingPassthroughSubject = showLoadingPassthroughSubject
        self.descriptionTextWithEmailUpdatePassthroughSubject = descriptionTextWithEmailUpdatePassthroughSubject
        self.initialDescriptionTextWithEmail = initialDescriptionTextWithEmail
    }
}
