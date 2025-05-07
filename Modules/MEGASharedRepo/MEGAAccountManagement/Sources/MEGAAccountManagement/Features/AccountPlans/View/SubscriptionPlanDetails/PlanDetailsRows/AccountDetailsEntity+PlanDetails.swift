// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public extension AccountDetailsEntity {
    /// This function returns a displayable plan for account plan (non-feature plans).
    /// Feature plan displayable will be handled in the apps that uses that certain features
    func accountPlanDisplayable(
        _ subscribeAction: @escaping () -> Void
    ) -> PlanDetailsRowViewModel? {
        accountPlanDisplayable(false, subscribeAction)
    }

    /// This function returns a displayable plan for account plan (non-feature plans).
    /// Feature plan displayable will be handled in the apps that uses that certain features
    func accountPlanDisplayable(
        _ isEligibleForFreeTrial: Bool,
        _ subscribeAction: @escaping () -> Void,
        now: Date = Date()
    ) -> PlanDetailsRowViewModel? {
        switch accountPlan {
        case .some(let plan) where plan.type == .business:
            return businessPlanDisplayable(plan, accountPlanSubscription, now: now)
        case .some(let plan) where plan.type == .free:
            return freePlanDisplayable(isEligibleForFreeTrial, subscribeAction)
        case .none where plans.isEmpty:
            return freePlanDisplayable(isEligibleForFreeTrial, subscribeAction)
        case .some(let plan) where plan.type.isAccountPlan :
            return proPlanDisplayable(plan, accountPlanSubscription, now: now)
        default: // feature plans
            return nil
        }
    }

    // MARK: - Free

    func freePlanDisplayable(
        _ isEligibleForFreeTrial: Bool,
        _ subscribeAction: @escaping () -> Void
    ) -> PlanDetailsRowViewModel {
        PlanDetailsRowViewModel(
            name: SharedStrings.Localizable.Subscriptions.FreePlan.title,
            buttons: [
                MEGAButton(
                    isEligibleForFreeTrial
                        ? SharedStrings.Localizable.SubscriptionPlanDetails.ButtonText.startFreeTrial
                        : SharedStrings.Localizable.SubscriptionPlanDetails.ButtonText.subscribe,
                    action: subscribeAction
                )
            ]
        )
    }

    // MARK: - Pro Plan

    private func proPlanDisplayable(
        _ accountPlan: AccountPlanEntity,
        _ accountSubscription: AccountSubscriptionEntity?,
        now: Date
    ) -> PlanDetailsRowViewModel {
        PlanDetailsRowViewModel(
            name: accountPlan.type.displayName,
            isTrial: accountPlan.isTrial,
            expiryDate: accountPlan.expiry,
            renewDate: accountPlanSubscription?.renewTime,
            features: now.timeIntervalSince1970 >= accountPlan.expiry ? [] : proPlanFeatures,
            footer: proPlanFooter
        )
    }

    private var proPlanFooter: String {
        switch accountPlanSubscription?.paymentMethod {
        case .some(let method) where method == .appleAppStore || method == .googlePlayStore:
            return SharedStrings.Localizable.SubscriptionPlanDetails.MegaApp.footer
        default:
            return SharedStrings.Localizable.SubscriptionPlanDetails.WebClient.footer
        }
    }

    private var proPlanFeatures: [PlanDetailsRowViewModel.Feature] {
        proPlanFeaturePlans + [
            moreStorageFeature,
            unrestrictedMeetingsFeature,
            passwordProtectedLinksFeature,
            rewindFilesFeature
        ]
    }

    private var proPlanFeaturePlans: [PlanDetailsRowViewModel.Feature] {
        if DependencyInjection.prioritizeVPNFeature {
            [accessToVpnFeature, accessToPWMFeature]
        } else {
            [accessToPWMFeature, accessToVpnFeature]
        }
    }

    // MARK: - Business

    private func businessPlanDisplayable(
        _ accountPlan: AccountPlanEntity,
        _ accountSubscription: AccountSubscriptionEntity?,
        now: Date
    ) -> PlanDetailsRowViewModel {
        PlanDetailsRowViewModel(
            name: accountPlan.type.displayName,
            isTrial: accountPlan.isTrial,
            expiryDate: accountPlan.expiry,
            renewDate: accountPlanSubscription?.renewTime,
            features: now.timeIntervalSince1970 >= accountPlan.expiry ? [] : proPlanFeatures,
            footer: SharedStrings.Localizable.SubscriptionPlanDetails.WebClient.footer
        )
    }

    // MARK: - Features

    private var accessToPWMFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("magicWandMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.AccessMegaPassFeature.title
        )
    }

    private var accessToVpnFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("ZapMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureOne.title
        )
    }

    private var moreStorageFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("CloudMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureTwo.title
        )
    }

    private var unrestrictedMeetingsFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("VideoMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureThree.title
        )
    }

    private var passwordProtectedLinksFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("LinkMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureFour.title
        )
    }

    private var rewindFilesFeature: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("ClockMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureFive.title
        )
    }

    private var hiddenFilesAndFolders: PlanDetailsRowViewModel.Feature {
        .init(
            icon: Image("EyeMediumThinOutline", bundle: .module),
            name: SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.FeatureSix.title
        )
    }
}

