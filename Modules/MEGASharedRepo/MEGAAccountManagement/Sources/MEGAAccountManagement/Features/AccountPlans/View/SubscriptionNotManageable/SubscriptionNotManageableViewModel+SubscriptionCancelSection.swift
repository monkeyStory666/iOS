// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGASharedRepoL10n
import SwiftUI

// swiftlint:disable line_length
extension SubscriptionNotManageableViewModel {
    struct SubscriptionCancelStepsGroup: Equatable {
        let title: String
        let isInitiallySelected: Bool
        let sections: [SubscriptionCancelStepsSection]

        init(
            title: String = "",
            isInitiallySelected: Bool = false,
            sections: [SubscriptionCancelStepsSection]
        ) {
            self.title = title
            self.isInitiallySelected = isInitiallySelected
            self.sections = sections
        }
    }

    struct SubscriptionCancelStep: Equatable {
        let text: String
        let index: Int
        let link: URL?

        init(text: String, index: Int, link: URL? = nil) {
            self.text = text
            self.index = index
            self.link = link
        }

        var titleFont: Font {
            link != nil ? .callout : .subheadline
        }

        var substringFont: Font {
            link != nil ? .callout : .subheadline.bold()
        }

        var substringColor: Color {
            link != nil ? TokenColors.Link.primary.swiftUI : TokenColors.Text.primary.swiftUI
        }
    }

    struct SubscriptionCancelStepsSection: Equatable {
        let title: String
        let steps: [SubscriptionCancelStep]

        // swiftlint:disable:next function_body_length
        static func generateCancelThroughGoogleSections() -> [SubscriptionCancelStepsSection] {
            return [
                .init(
                    title: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.title,
                    steps: [
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.visitGooglePlay,
                            index: 1,
                            link: Constants.Link.playStore
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.signInWithGooglePlayAccount,
                            index: 2
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.clickYourAvatar,
                            index: 3
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.clickPaymentsAndSubscriptions,
                            index: 4
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.clickSubscriptionsTab,
                            index: 5
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.WebBrowserSection.clickCancel,
                            index: 6
                        )
                    ]
                ),
                .init(
                    title: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.title,
                    steps: [
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.openPlayStoreApp,
                            index: 1
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.signInWithGooglePlayAccountIfNeeded,
                            index: 2
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.tapYourAvatar,
                            index: 3
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.tapPaymentsAndSubscriptions,
                            index: 4
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.tapSubscriptionsTab,
                            index: 5
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Google.AndroidSection.cancelSubscription,
                            index: 6
                        )
                    ]
                )
            ]
        }

        // swiftlint:disable:next function_body_length
        static func generateCancelThroughWebSections() -> [SubscriptionCancelStepsSection] {
            return [
                .init(
                    title: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnComputerSection.title,
                    steps: [
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.General.visitMegaWebsite,
                            index: 1,
                            link: Constants.Link.megaWebsite
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.General.loginWithMegaAccount,
                            index: 2
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnComputerSection.openMainMenu,
                            index: 3
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnComputerSection.clickSettings,
                            index: 4
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnComputerSection.clickPlanTab,
                            index: 5
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnComputerSection.clickCancel,
                            index: 6
                        )
                    ]
                ),
                .init(
                    title: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnMobileDeviceSection.title,
                    steps: [
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.General.visitMegaWebsite,
                            index: 1,
                            link: Constants.Link.megaWebsite
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.General.loginWithMegaAccount,
                            index: 2
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnMobileDeviceSection.tapYourAvatar,
                            index: 3
                        ),
                        .init(
                            text: SharedStrings.Localizable.SubscriptionNotManageableScreen.Web.OnMobileDeviceSection.tapCancelSubscription,
                            index: 4
                        )
                    ]
                )
            ]
        }
    }
}
// swiftlint:enable line_length
