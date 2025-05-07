// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAAnalytics
import MEGAPresentation
import SwiftUI

public final class WhatsNewScreenViewModel: ViewModel<WhatsNewScreenViewModel.Route> {
    public enum Route {
        case dismissed
        case primaryButtonRoute
        case secondaryButtonRoute
    }

    public enum ImageDisplayMode {
        case regular(Image)
        case small(Image)
        case fillScreenWidth(Image)
        case hidden

        var isFillScreenWidth: Bool {
            switch self {
            case .fillScreenWidth:
                true
            default:
                false
            }
        }

        var isHeaderImageDisplayed: Bool {
            switch self {
            case .hidden:
                false
            default:
                true
            }
        }
    }

    public struct HeaderImage {
        let mode: ImageDisplayMode
        let image: Image
    }

    public struct RowItem {
        let title: String
        let subtitle: String
        let image: Image

        public init(title: String, subtitle: String, image: Image) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
        }
    }

    public struct Config {
        let imageDisplayMode: ImageDisplayMode
        let headlineText: AttributedString
        let smallTitleText: AttributedString?
        let bodyText: AttributedString?
        let textAlignment: TextAlignment
        let footerText: AttributedString?
        let rows: [RowItem]
        let hasDismissButton: Bool
        let primaryButtonText: String
        let secondaryButtonText: String

        public init(
            imageDisplayMode: ImageDisplayMode,
            headlineText: AttributedString,
            smallTitleText: AttributedString? = nil,
            bodyText: AttributedString? = nil,
            textAlignment: TextAlignment = .leading,
            footerText: AttributedString? = nil,
            rows: [RowItem] = [],
            hasDismissButton: Bool = false,
            primaryButtonText: String,
            secondaryButtonText: String
        ) {
            self.imageDisplayMode = imageDisplayMode
            self.headlineText = headlineText
            self.smallTitleText = smallTitleText
            self.bodyText = bodyText
            self.textAlignment = textAlignment
            self.footerText = footerText
            self.rows = rows
            self.hasDismissButton = hasDismissButton
            self.primaryButtonText = primaryButtonText
            self.secondaryButtonText = secondaryButtonText
        }
    }

    private let analyticsTracker: any MEGAAnalyticsTrackerProtocol

    var ignoresSafeAreaEdges: Edge.Set {
        config.imageDisplayMode.isFillScreenWidth ? [.top] : []
    }

    let config: Config

    public init(
        config: Config,
        analyticsTracker: some MEGAAnalyticsTrackerProtocol
    ) {
        self.config = config
        self.analyticsTracker = analyticsTracker
    }

    func primaryButtonAction() {
        analyticsTracker.trackAnalyticsEvent(with: .whatsNewScreenPrimaryButtonPressed)
        routeTo(.primaryButtonRoute)
    }

    func secondaryButtonAction() {
        analyticsTracker.trackAnalyticsEvent(with: .whatsNewScreenSecondaryButtonPressed)
        routeTo(.secondaryButtonRoute)
    }

    func dismiss() {
        routeTo(.dismissed)
    }
}
