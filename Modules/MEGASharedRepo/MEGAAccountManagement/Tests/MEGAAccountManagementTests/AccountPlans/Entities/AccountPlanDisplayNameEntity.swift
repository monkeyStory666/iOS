// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAccountManagement
import MEGASharedRepoL10n
import Testing

struct AccountPlanDisplayNameEntityTests {
    struct DisplayNameArguments {
        let planName: String
        let isFeaturePlan: Bool
        let isTrial: Bool
        let expectedDisplayName: String
    }

    @Test(
        arguments: [
            DisplayNameArguments(
                planName: "MEGA VPN",
                isFeaturePlan: false,
                isTrial: false,
                expectedDisplayName: "MEGA VPN"
            ),
            DisplayNameArguments(
                planName: "MEGA VPN",
                isFeaturePlan: true,
                isTrial: false,
                expectedDisplayName: "MEGA VPN plan"
            ),
            DisplayNameArguments(
                planName: "MEGA VPN",
                isFeaturePlan: false,
                isTrial: true,
                expectedDisplayName: "MEGA VPN free trial"
            ),
            DisplayNameArguments(
                planName: "MEGA VPN",
                isFeaturePlan: true,
                isTrial: true,
                expectedDisplayName: "MEGA VPN free trial"
            ),
        ] as [DisplayNameArguments]
    ) func displayName(arguments: DisplayNameArguments) {
        #expect(
            AccountPlanDisplayNameEntity.displayName(
                planName: arguments.planName,
                isFeaturePlan: arguments.isFeaturePlan,
                isTrial: arguments.isTrial
            ) == arguments.expectedDisplayName
        )
    }

    struct DisplaySubtitleArguments {
        let isTrial: Bool
        let renewDate: TimeInterval?
        let expiryDate: TimeInterval?
        let currentTime: TimeInterval
        let expectedSubtitle: String?
    }

    @Test(
        arguments: [
            DisplaySubtitleArguments(
                isTrial: false,
                renewDate: testExpiryDate,
                expiryDate: nil,
                currentTime: testExpiryDate - oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.renewsOn(testExpiryDateString)
            ),
            DisplaySubtitleArguments(
                isTrial: false,
                renewDate: nil,
                expiryDate: testExpiryDate,
                currentTime: testExpiryDate - oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.expiresOn(testExpiryDateString)
            ),
            DisplaySubtitleArguments(
                isTrial: false,
                renewDate: nil,
                expiryDate: testExpiryDate,
                currentTime: testExpiryDate + oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.expired
            ),
            DisplaySubtitleArguments(
                isTrial: true,
                renewDate: testExpiryDate,
                expiryDate: nil,
                currentTime: testExpiryDate - oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(testExpiryDateString)
            ),
            DisplaySubtitleArguments(
                isTrial: true,
                renewDate: nil,
                expiryDate: testExpiryDate,
                currentTime: testExpiryDate - oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(testExpiryDateString)
            ),
            DisplaySubtitleArguments(
                isTrial: true,
                renewDate: nil,
                expiryDate: testExpiryDate,
                currentTime: testExpiryDate + oneMonth,
                expectedSubtitle: SharedStrings.Localizable.SubscriptionPlanDetails.expired
            ),
            DisplaySubtitleArguments(
                isTrial: false,
                renewDate: nil,
                expiryDate: nil,
                currentTime: testExpiryDate - oneMonth,
                expectedSubtitle: nil
            ),
        ] as [DisplaySubtitleArguments]
    ) func displaySubtitle(arguments: DisplaySubtitleArguments) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        #expect(
            AccountPlanDisplayNameEntity.displaySubtitle(
                isTrial: arguments.isTrial,
                renewDate: arguments.renewDate,
                expiryDate: arguments.expiryDate,
                now: Date(timeIntervalSince1970: arguments.currentTime),
                dateFormatter: dateFormatter
            ) == arguments.expectedSubtitle
        )
    }
}

private var oneDay: TimeInterval { 86_400 }
private var oneMonth: TimeInterval { oneDay * 30 }
private var testExpiryDate: TimeInterval { 1_724_907_803 }
private var testExpiryDateString: String { "8/29/24" }
