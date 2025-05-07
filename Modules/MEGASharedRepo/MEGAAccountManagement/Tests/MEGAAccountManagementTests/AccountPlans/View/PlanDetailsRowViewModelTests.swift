// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import Foundation
import MEGASharedRepoL10n
import Testing

struct PlanDetailsRowViewModelTests {
    @Test func displayName_forTrialPlan() {
        let sut = makePlanDetails(
            name: "Pro Plan",
            isTrial: true
        )

        #expect(
            sut.displayName == AccountPlanDisplayNameEntity.displayName(
                planName: "Pro Plan",
                isFeaturePlan: false,
                isTrial: true
            )
        )
    }
    
    @Test func displayName_forNonTrialPlan() {
        let sut = makePlanDetails(
            name: "Pro Plan",
            isTrial: false
        )

        #expect(sut.displayName == "Pro Plan")
    }
    
    @Test func dateString_withRenewDateForTrialPlan() {
        let sut = makePlanDetails(
            isTrial: true,
            renewDate: testExpiryDate
        )

        #expect(
            sut.dateString ==
            SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(testExpiryDateString)
        )
    }
    
    @Test func dateString_withRenewDateForNonTrialPlan() {
        let sut = makePlanDetails(
            isTrial: false,
            renewDate: testExpiryDate
        )

        #expect(
            sut.dateString ==
            SharedStrings.Localizable.SubscriptionPlanDetails.renewsOn(testExpiryDateString)
        )
    }
    
    @Test func dateString_withExpiryDateForTrialPlan() {
        let sut = makePlanDetails(
            isTrial: true,
            expiryDate: testExpiryDate
        )

        #expect(
            sut.dateString ==
            SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(testExpiryDateString)
        )
    }
    
    @Test func dateString_withExpiryDateForNonTrialPlan() {
        let sut = makePlanDetails(
            isTrial: false,
            expiryDate: testExpiryDate
        )

        #expect(
            sut.dateString ==
            SharedStrings.Localizable.SubscriptionPlanDetails.expiresOn(testExpiryDateString)
        )
    }
    
    @Test func dateString_withNoRenewOrExpiryDate() {
        let sut = makePlanDetails()

        #expect(sut.dateString == nil)
    }

    // MARK: - Test Helpers

    private func makePlanDetails(
        name: String = "Pro Plan",
        isTrial: Bool = false,
        expiryDate: TimeInterval? = nil,
        renewDate: TimeInterval? = nil,
        price: String? = nil,
        buttonText: String? = nil,
        features: [PlanDetailsRowViewModel.Feature] = [],
        footer: String? = nil,
        buttonAction: (
    () -> Void
        )? = nil,
        now: Date = Date(timeIntervalSince1970: testExpiryDate - 86_400)
    ) -> PlanDetailsRowViewModel {
        return PlanDetailsRowViewModel(
            name: name,
            isTrial: isTrial,
            expiryDate: expiryDate,
            renewDate: renewDate,
            price: price,
            buttonText: buttonText,
            features: features,
            footer: footer,
            dateFormatter: {
                $0.dateStyle = .short
                $0.locale = Locale(identifier: "en_US")
                return $0
            }(DateFormatter()),
            buttonAction: buttonAction,
            now: now
        )
    }
}

private var testExpiryDate: TimeInterval { 1_724_907_803 }
private var testExpiryDateString: String { "8/29/24" }
