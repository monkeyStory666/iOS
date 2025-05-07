// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAAnalyticsMock
import MEGACancelSurvey
import MEGACancelSurveyMocks
import MEGAUIComponent
import Testing

struct CancelSurveyScreenViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.happyToHelpChecked == false)
        #expect(sut.selectedOptions.isEmpty)
        #expect(sut.otherOptionSelected == false)
        #expect(sut.otherOptionText.isEmpty)
        #expect(sut.route == nil)
    }

    struct ContinueButtonStateArguments: Sendable {
        let selectedOptions: [Int]
        let otherOptionSelected: Bool
        let expectedState: MEGAButtonState
    }

    @Test(
        arguments: [
            ContinueButtonStateArguments(
                selectedOptions: [],
                otherOptionSelected: false,
                expectedState: .disabled
            ),
            ContinueButtonStateArguments(
                selectedOptions: [1, 6],
                otherOptionSelected: false,
                expectedState: .default
            ),
            ContinueButtonStateArguments(
                selectedOptions: [],
                otherOptionSelected: true,
                expectedState: .default
            ),
            ContinueButtonStateArguments(
                selectedOptions: [1, 6],
                otherOptionSelected: true,
                expectedState: .default
            )
        ]
    ) func continueButtonState(arguments: ContinueButtonStateArguments) {
        let sut = makeSUT()

        sut.selectedOptions = arguments.selectedOptions
        sut.otherOptionSelected = arguments.otherOptionSelected

        #expect(sut.continueButtonState == arguments.expectedState)
    }

    @Test func shouldHideOtherOptionInputField() {
        let sut = makeSUT()

        sut.otherOptionSelected = false
        #expect(sut.shouldHideOtherOptionInputField == true)

        sut.otherOptionSelected = true
        #expect(sut.shouldHideOtherOptionInputField == false)
    }

    @Test func didTapCloseButton_shouldRouteToDismissed_andSendAnalyticsEvent() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.didTapCloseButton()

        #expect(sut.route == .dismissed)
        mockTracker.swt.assertsEventsEqual(to: [.cancelSurveyCloseButtonPressed])
    }

    @Test func didTapDontCancel_shouldRouteToDismissed_andSendAnalyticsEvent() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.didTapDontCancel()

        #expect(sut.route == .dismissed)
        mockTracker.swt.assertsEventsEqual(to: [.cancelSurveyDontCancelButtonPressed])
    }

    @Test func didTapSkip_shouldSkipSurvey_andRouteToFinished_andSendAnalyticsEvent() async {
        let mockTracker = MockAnalyticsTracking()
        let expectedSubscriptionId = String.random()
        let mockUseCase = MockCancelSurveyUseCase()
        let sut = makeSUT(
            subscriptionId: expectedSubscriptionId,
            cancelSurveyUseCase: mockUseCase,
            analyticsTracker: mockTracker
        )

        await sut.didTapSkip()

        mockUseCase.swt.assertActions(shouldBe: [.skippedSurvey(subscriptionId: expectedSubscriptionId)])
        #expect(sut.route == .finished)
        mockTracker.swt.assertsEventsEqual(to: [.cancelSurveySkipButtonPressed])
    }

    @Test func didTapHappyToHelpCheckbox() {
        let sut = makeSUT()

        sut.didTapHappyToHelpCheckbox()
        #expect(sut.happyToHelpChecked == true)

        sut.didTapHappyToHelpCheckbox()
        #expect(sut.happyToHelpChecked == false)
    }

    @Test func isSelected_whenOptionSelected_shouldReturnTrue() {
        let sut = makeSUT()

        sut.selectedOptions = [0, 2]

        #expect(sut.isSelected(option: sut.options[0]) == true)
        #expect(sut.isSelected(option: sut.options[1]) == false)
        #expect(sut.isSelected(option: sut.options[2]) == true)
    }

    @Test func isSelected_whenOptionDoesNotExist_shouldReturnFalse() {
        let sut = makeSUT()

        #expect(sut.isSelected(option: .init(text: "Non-existing option", displayText: "Non-existing option")) == false)
    }

    @Test func didTapOption_whenNotSelected_andOptionExists_shouldSelectOption() {
        let sut = makeSUT()

        sut.didTapOption(sut.options[0])

        #expect(sut.selectedOptions == [0])
    }

    @Test func didTapOption_whenSelected_andOptionExists_shouldDeselectOption() {
        let sut = makeSUT()

        sut.selectedOptions = [0, 2]
        sut.didTapOption(sut.options[0])

        #expect(sut.selectedOptions == [2])
    }

    @Test func didTapOtherOption() {
        let sut = makeSUT()

        sut.didTapOtherOption()
        #expect(sut.otherOptionSelected == true)

        sut.didTapOtherOption()
        #expect(sut.otherOptionSelected == false)
    }

    @Test func didTapContinue_shouldSubmitSurvey_andRouteToFinished_andSendEvent() async {
        let expectedSubscriptionId = String.random()
        let expectedHappyToHelp = Bool.random()
        let mockUseCase = MockCancelSurveyUseCase()
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(
            subscriptionId: expectedSubscriptionId,
            cancelSurveyUseCase: mockUseCase,
            analyticsTracker: mockTracker
        )
        sut.happyToHelpChecked = expectedHappyToHelp
        sut.selectedOptions = [0, 2]

        await sut.didTapContinue()

        mockUseCase.swt.assertActions(
            shouldBe: [.submitCancelSurvey(
                reasons: [
                    .init(text: sut.options[0].text, position: 1),
                    .init(text: sut.options[2].text, position: 3)
                ],
                subscriptionId: expectedSubscriptionId,
                canContact: expectedHappyToHelp
            )]
        )
        #expect(sut.route == .finished)
        mockTracker.swt.assertsEventsEqual(to: [.cancelSurveyContinueButtonPressed])
    }

    @Test func didTapContinue_whenOtherOptionSelected_shouldSubmitSurvey() async {
        let expectedSubscriptionId = String.random()
        let expectedHappyToHelp = Bool.random()
        let expectedOtherReason = String.random()
        let mockUseCase = MockCancelSurveyUseCase()
        let sut = makeSUT(
            subscriptionId: expectedSubscriptionId,
            cancelSurveyUseCase: mockUseCase
        )
        sut.selectedOptions = [99]
        sut.happyToHelpChecked = expectedHappyToHelp
        sut.otherOptionSelected = true
        sut.otherOptionText = expectedOtherReason

        await sut.didTapContinue()

        mockUseCase.swt.assertActions(
            shouldBe: [.submitCancelSurvey(
                reasons: [
                    .init(text: "Other: \(expectedOtherReason)", position: sut.options.count + 1)
                ],
                subscriptionId: expectedSubscriptionId,
                canContact: expectedHappyToHelp
            )]
        )
        #expect(sut.route == .finished)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        options: [CancelSurveyOption] = Self.testOptions,
        subscriptionId: String? = nil,
        cancelSurveyUseCase: CancelSurveyUseCaseProtocol = MockCancelSurveyUseCase(),
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking()
    ) -> CancelSurveyScreenViewModel {
        CancelSurveyScreenViewModel(
            options: options,
            subscriptionId: subscriptionId,
            cancelSurveyUseCase: cancelSurveyUseCase,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )
    }

    private static var testOptions: [CancelSurveyOption] {
        [
            .init(text: "Option 1", displayText: "Option 1 Display Text"),
            .init(text: "Option 2", displayText: "Option 2 Display Text"),
            .init(text: "Option 3", displayText: "Option 3 Display Text"),
            .init(text: "Option 4", displayText: "Option 4 Display Text"),
            .init(text: "Option 5", displayText: "Option 5 Display Text"),
            .init(text: "Option 6", displayText: "Option 6 Display Text"),
            .init(text: "Option 7", displayText: "Option 7 Display Text"),
            .init(text: "Option 8", displayText: "Option 8 Display Text")
        ]
    }
}
