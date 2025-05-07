// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASharedRepoL10n

public enum AccountPlanDisplayNameEntity {
    public static func displayName(
        planName: String,
        isFeaturePlan: Bool,
        isTrial: Bool
    ) -> String {
        if isTrial {
            SharedStrings.Localizable.SubscriptionPlanDetails.freeTrial(planName)
        } else if isFeaturePlan {
            SharedStrings.Localizable.SubscriptionPlanDetails.featurePlan(planName)
        } else {
            planName
        }
    }

    public static func displaySubtitle(
        isTrial: Bool,
        renewDate: TimeInterval? = nil,
        expiryDate: TimeInterval? = nil,
        now: Date = Date(),
        dateFormatter: DateFormatter = DateFormatter()
    ) -> String? {
        if let renewDate = renewDate?.toFormattedDateString(dateFormatter) {
            isTrial
                ? SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(renewDate)
                : SharedStrings.Localizable.SubscriptionPlanDetails.renewsOn(renewDate)
        } else if let expiryDate, now.timeIntervalSince1970 > expiryDate {
            SharedStrings.Localizable.SubscriptionPlanDetails.expired
        } else if let expiryDateString = expiryDate?.toFormattedDateString(dateFormatter) {
            isTrial
                ? SharedStrings.Localizable.SubscriptionPlanDetails.endsOn(expiryDateString)
                : SharedStrings.Localizable.SubscriptionPlanDetails.expiresOn(expiryDateString)
        } else {
            nil
        }
    }
}

private extension TimeInterval {
    func toFormattedDateString(_ dateFormatter: DateFormatter) -> String? {
        guard self != 0 else { return nil }

        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}

