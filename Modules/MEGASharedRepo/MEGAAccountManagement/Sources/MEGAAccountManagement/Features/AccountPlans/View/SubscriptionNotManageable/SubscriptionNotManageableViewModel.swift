// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGASharedRepoL10n
import SwiftUI

public final class SubscriptionNotManageableViewModel: Identifiable {
    public enum SubscriptionNotManageableType {
        case cancelThroughGoogle
        case cancelThroughWeb

        func groups() -> [SubscriptionCancelStepsGroup] {
            switch self {
            case .cancelThroughGoogle:
                return [
                    .init(
                        sections: SubscriptionCancelStepsSection.generateCancelThroughGoogleSections()
                    )
                ]
            case .cancelThroughWeb:
                return [
                    .init(sections: SubscriptionCancelStepsSection.generateCancelThroughWebSections())
                ]
            }
        }
    }

    var title: String {
        switch (type, isTrial) {
        case (.cancelThroughGoogle, false):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.title
        case (.cancelThroughWeb, false):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.title
        case (.cancelThroughGoogle, true):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.FreeTrial.Google.title
        case (.cancelThroughWeb, true):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.FreeTrial.Web.title
        }
    }

    var subtitle: String {
        switch (type, isTrial) {
        case (.cancelThroughGoogle, false):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.subtitle
        case (.cancelThroughWeb, false):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.subtitle
        case (.cancelThroughGoogle, true):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.FreeTrial.Google.subtitle
        case (.cancelThroughWeb, true):
            SharedStrings.Localizable.SubscriptionNotManageableScreen.FreeTrial.Web.subtitle
        }
    }

    var subscriptionCancelStepsGroups: [SubscriptionCancelStepsGroup] {
        type.groups()
    }

    private let externalLinkOpener: ExternalLinkOpening
    private let type: SubscriptionNotManageableType
    private let isTrial: Bool

    public init(
        externalLinkOpener: ExternalLinkOpening = MEGAInfrastructure.DependencyInjection.externalLinkOpener,
        for type: SubscriptionNotManageableType,
        isTrial: Bool
    ) {
        self.externalLinkOpener = externalLinkOpener
        self.type = type
        self.isTrial = isTrial
    }

    func openURL(_ url: URL?) {
        guard let url else { return }
        externalLinkOpener.openExternalLink(with: url)
    }
}
