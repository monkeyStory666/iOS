// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Testing

struct SubscriptionNotManageableViewModelTests {
    @Test func whenCancelThroughGoogle_shouldGenerateCorrectInformation() {
        let sut = makeSUT(with: .cancelThroughGoogle)

        #expect(sut.subscriptionCancelStepsGroups.count == 1)

        let subscriptionCancelGroup = sut.subscriptionCancelStepsGroups[0]
        #expect(subscriptionCancelGroup.sections[0].title == "In a web browser")
        #expect(subscriptionCancelGroup.sections[1].title == "On an Android device")

        #expect(subscriptionCancelGroup.sections[0].steps.count == 6)
        #expect(subscriptionCancelGroup.sections[1].steps.count == 6)
    }

    @Test func whenCancelThroughWeb_shouldGenerateCorrectInformation() {
        let sut = makeSUT(with: .cancelThroughWeb)

        #expect(sut.subscriptionCancelStepsGroups.count == 1)

        let subscriptionCancelGroup = sut.subscriptionCancelStepsGroups[0]
        #expect(subscriptionCancelGroup.sections[0].title == "On a computer")
        #expect(subscriptionCancelGroup.sections[1].title == "On a mobile device")

        #expect(subscriptionCancelGroup.sections[0].steps.count == 6)
        #expect(subscriptionCancelGroup.sections[1].steps.count == 4)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        with type: SubscriptionNotManageableViewModel.SubscriptionNotManageableType
    ) -> SubscriptionNotManageableViewModel {
        SubscriptionNotManageableViewModel(for: type, isTrial: .random())
    }
}
