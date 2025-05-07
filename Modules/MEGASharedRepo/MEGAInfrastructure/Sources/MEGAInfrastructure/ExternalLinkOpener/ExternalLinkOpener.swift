// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import UIKit

public protocol ExternalLinkOpening {
    func openExternalLink(with url: URL)
    func openExternalLink(with url: URL, fallbackURL: URL)
    func canOpenLink(with url: URL) -> Bool
    func openExternalLinkFromExtension(url: URL, from viewController: UIViewController)
}

public struct ExternalLinkOpener: ExternalLinkOpening {
    private let runInMainThread: (@escaping () -> Void) -> Void
    private let canOpenURL: (URL) -> Bool
    private let openURL: (URL) -> Void
    private let openURLWithCompletion: (URL, @escaping (Bool) -> Void) -> Void
    private let openURLFromViewController: (URL, UIViewController) -> Void

    public init(
        runInMainThread: @escaping (@escaping () -> Void) -> Void,
        canOpenURL: @escaping (URL) -> Bool,
        openURL: @escaping (URL) -> Void,
        openURLWithCompletion: @escaping (URL, @escaping (Bool) -> Void) -> Void,
        openURLFromViewController: @escaping (URL, UIViewController) -> Void
    ) {
        self.runInMainThread = runInMainThread
        self.canOpenURL = canOpenURL
        self.openURL = openURL
        self.openURLWithCompletion = openURLWithCompletion
        self.openURLFromViewController = openURLFromViewController
    }

    public func openExternalLink(with url: URL, fallbackURL: URL) {
        runInMainThread {
            openURLWithCompletion(url) { isCompleted in
                guard !isCompleted else { return }

                openExternalLink(with: fallbackURL)
            }
        }
    }

    public func openExternalLink(with url: URL) {
        runInMainThread {
            openURL(url)
        }
    }

    public func canOpenLink(with url: URL) -> Bool {
        canOpenURL(url)
    }

    /// 'UIApplication.shared' is unavailable in application extensions for iOS
    /// Use view controller based solutions to open URLs in extensions
    public func openExternalLinkFromExtension(
        url: URL,
        from viewController: UIViewController
    ) {
        openURLFromViewController(url, viewController)
    }
}
