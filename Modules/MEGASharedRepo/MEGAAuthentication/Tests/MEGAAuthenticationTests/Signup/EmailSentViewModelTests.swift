// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Combine
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAuthenticationMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGAUIComponent
import Testing

struct EmailSentViewModelTests {
    @Test func testInitState() {
        let configuration = MockEmailSentConfiguration()
        let sut = makeSUT(configuration: configuration)

        #expect(sut.headerTitle == configuration.headerTitle)
        #expect(sut.primaryButtonTitle == configuration.primaryButtonTitle)
        #expect(sut.secondaryButtonTitle == configuration.secondaryButtonTitle)

        #expect(sut.primaryButtonState == MEGAButtonStyle.State.default)
        #expect(sut.secondaryButtonState == MEGAButtonStyle.State.default)
        #expect(sut.showLoading == false)
        #expect(sut.descriptionTextWithEmail == configuration.descriptionTextWithEmail)
    }

    @Test func testDidTapCloseButton_whenPerformed_shouldDismissView() {
        let sut = makeSUT()
        sut.didTapCloseButton()
        #expect(sut.route == .dismissed)
    }

    @Test func testPrimaryButtonPressed_whenPerformed_shouldTrackAnalyticsEvent_andDismissView() {
        let analyticsTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker))
        sut.primaryButtonPressed()

        analyticsTracker.swt.assertsEventsEqual(to: [.resendEmailConfirmationButtonPressed])
        #expect(sut.route == .primaryButtonPressed)
    }

    @Test func testSecondaryButtonPressed_whenPerformed_shouldDismissView() {
        let sut = makeSUT()
        sut.secondaryButtonPressed()
        #expect(sut.route == .secondaryButtonPressed)
    }

    @Test func testSendEmailToSupport() async {
        let supportEmailPresenter = MockEmailPresenter()
        let sut = makeSUT(supportEmailPresenter: supportEmailPresenter)
        await sut.sendEmailToSupport()
        supportEmailPresenter.swt.assertActions(shouldBe: [.presentMailCompose])
    }

    @Test func testSupportTextWithEmail_whenFetched_shouldMatch() {
        let sut = makeSUT()
        let expectedSupportTextWithEmail = DisplayTextWithEmail(
            text: SharedStrings.Localizable.ConfirmationText.Support.message,
            email: Constants.Email.support,
            displayOption: .link(action: {})
        )
        #expect(sut.supportTextWithEmail == expectedSupportTextWithEmail)
    }

    @Test func testPrimaryButtonState_whenUpdated_shouldMatch() {
        let subject = PassthroughSubject<MEGAButtonStyle.State, Never>()
        let configuration = MockEmailSentConfiguration(primaryButtonStatePassthroughSubject: subject)
        let sut = makeSUT(configuration: configuration)
        #expect(sut.primaryButtonState == MEGAButtonStyle.State.default)
        subject.send(.load)
        #expect(sut.primaryButtonState == MEGAButtonStyle.State.load)
        subject.send(.default)
        #expect(sut.primaryButtonState == MEGAButtonStyle.State.default)
    }

    @Test func testSecondaryButtonState_whenUpdated_shouldMatch() {
        let subject = PassthroughSubject<MEGAButtonStyle.State, Never>()
        let configuration = MockEmailSentConfiguration(secondaryButtonStatePassthroughSubject: subject)
        let sut = makeSUT(configuration: configuration)
        #expect(sut.secondaryButtonState == MEGAButtonStyle.State.default)
        subject.send(.load)
        #expect(sut.secondaryButtonState == MEGAButtonStyle.State.load)
        subject.send(.default)
        #expect(sut.secondaryButtonState == MEGAButtonStyle.State.default)
    }

    @Test func testShowLoading_whenUpdated_shouldMatch() {
        let subject = PassthroughSubject<Bool, Never>()
        let configuration = MockEmailSentConfiguration(showLoadingPassthroughSubject: subject)
        let sut = makeSUT(configuration: configuration)
        #expect(sut.showLoading == false)
        subject.send(true)
        #expect(sut.showLoading)
        subject.send(false)
        #expect(sut.showLoading == false)
    }

    @Test func testDescriptionTextWithEmail_whenUpdated_shouldMatch() {
        let subject = PassthroughSubject<DisplayTextWithEmail, Never>()
        let initialDescription = DisplayTextWithEmail(text: "text", email: "email@email.com", displayOption: .none)
        let configuration = MockEmailSentConfiguration(
            descriptionTextWithEmailUpdatePassthroughSubject: subject,
            initialDescriptionTextWithEmail: initialDescription
        )
        let sut = makeSUT(configuration: configuration)
        #expect(sut.descriptionTextWithEmail == initialDescription)

        let updatedDescription = DisplayTextWithEmail(
            text: "updatedText", email: "updatedEmail@email.com", displayOption: .none
        )
        subject.send(updatedDescription)
        #expect(sut.descriptionTextWithEmail == updatedDescription)

    }

    // MARK: - Private methods

    private typealias SUT = EmailSentViewModel

    private func makeSUT(
        configuration: some EmailSentConfigurable = MockEmailSentConfiguration(),
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking()),
        supportEmailPresenter: some EmailPresenting = MockEmailPresenter()
    ) -> SUT {
        EmailSentViewModel(
            configuration: configuration,
            analyticsTracker: analyticsTracker,
            supportEmailPresenter: supportEmailPresenter
        )
    }

}
