// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest
import UIKit

public final class MockExternalLinkOpener:
    MockObject<MockExternalLinkOpener.Action>,
    ExternalLinkOpening {
    public enum Action: Equatable {
        case openExternalLink(URL)
        case openExternalLinkWithFallback(_ url: URL, _ fallbackURL: URL)
        case canOpenLink(_ url: URL)
        case openExternalLinkFromExtension(url: URL)
    }

    private let canOpenLink: Bool

    public init(canOpenLink: Bool = true) {
        self.canOpenLink = canOpenLink
    }

    public func openExternalLink(with url: URL) {
        actions.append(.openExternalLink(url))
    }

    public func openExternalLink(with url: URL, fallbackURL: URL) {
        actions.append(.openExternalLinkWithFallback(url, fallbackURL))
    }

    public func canOpenLink(with url: URL) -> Bool {
        actions.append(.canOpenLink(url))
        return canOpenLink
    }

    public func openExternalLinkFromExtension(url: URL, from viewController: UIViewController) {
        actions.append(.openExternalLinkFromExtension(url: url))
    }
}
