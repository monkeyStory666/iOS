// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAUIComponent
import MEGAPresentation
import SwiftUI

public final class CancelSurveyScreenViewModel: ViewModel<CancelSurveyScreenViewModel.Route> {
    public enum Route {
        case dismissed
        case finished
    }

    @ViewProperty public var happyToHelpChecked = false
    @ViewProperty public var selectedOptions: [Int] = []
    @ViewProperty public var otherOptionSelected = false

    /// We use @Published here because @ViewProperty will cause the cursor
    /// to be moved to the end when text is changed at the middle. The reason
    /// could be that the dispatch to main thread logic of ViewProperty does not
    /// work well with TextField/TextEditor cursor
    @Published public var otherOptionText: String = ""

    public let otherOptionCharacterLimit: Int = 120

    public let options: [CancelSurveyOption]

    private let subscriptionId: String?
    private let cancelSurveyUseCase: any CancelSurveyUseCaseProtocol
    private let analyticsTracker: any MEGAAnalyticsTrackerProtocol

    public init(
        options: [CancelSurveyOption],
        subscriptionId: String?,
        cancelSurveyUseCase: some CancelSurveyUseCaseProtocol,
        analyticsTracker: some MEGAAnalyticsTrackerProtocol
    ) {
        self.options = options.shuffled()
        self.subscriptionId = subscriptionId
        self.cancelSurveyUseCase = cancelSurveyUseCase
        self.analyticsTracker = analyticsTracker
    }

    public var continueButtonState: MEGAButtonState {
        selectedOptions.isEmpty && !otherOptionSelected
            ? .disabled
            : .default
    }

    public var shouldHideOtherOptionInputField: Bool {
        !otherOptionSelected
    }

    public func onAppear() {
        analyticsTracker.trackAnalyticsEvent(with: .cancelSurveyScreenView)
    }

    public func didTapCloseButton() {
        analyticsTracker.trackAnalyticsEvent(with: .cancelSurveyCloseButtonPressed)
        routeTo(.dismissed)
    }

    public func didTapDontCancel() {
        analyticsTracker.trackAnalyticsEvent(with: .cancelSurveyDontCancelButtonPressed)
        routeTo(.dismissed)
    }

    public func didTapSkip() async {
        analyticsTracker.trackAnalyticsEvent(with: .cancelSurveySkipButtonPressed)
        try? await cancelSurveyUseCase.skippedSurvey(subscriptionId: subscriptionId)
        routeTo(.finished)
    }

    public func didTapContinue() async {
        analyticsTracker.trackAnalyticsEvent(with: .cancelSurveyContinueButtonPressed)
        try? await cancelSurveyUseCase.submitCancelSurvey(
            reasons: selectedReasons(),
            subscriptionId: subscriptionId,
            canContact: happyToHelpChecked
        )
        routeTo(.finished)
    }

    public func didTapHappyToHelpCheckbox() {
        happyToHelpChecked.toggle()
    }

    public func isSelected(option: CancelSurveyOption) -> Bool {
        guard let optionIndex = index(for: option) else { return false }

        return selectedOptions.contains(optionIndex)
    }

    public func didTapOption(_ option: CancelSurveyOption) {
        if isSelected(option: option) {
            selectedOptions.removeAll { $0 == index(for: option) }
        } else if let optionIndex = index(for: option) {
            selectedOptions.append(optionIndex)
        }
    }

    private func index(for option: CancelSurveyOption) -> Int? {
        options.firstIndex(of: option)
    }

    public func didTapOtherOption() {
        otherOptionSelected.toggle()
    }

    private func selectedReasons() -> [CancelSurveySelectedReason] {
        var selectedReasons: [CancelSurveySelectedReason] = selectedOptions.compactMap { optionIndex in
            guard options.count > optionIndex else { return nil }

            return CancelSurveySelectedReason(
                text: options[optionIndex].text,
                position: optionIndex + 1
            )
        }

        if otherOptionSelected {
            selectedReasons.append(
                CancelSurveySelectedReason(
                    text: "Other: \(otherOptionText)",
                    position: options.count + 1
                )
            )
        }

        return selectedReasons
    }
}
