// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import Testing
import UIKit

final class ExternalLinkOpenerTests {
    private var urlOpened = [URL]()
    private var completionHandlers: [((Bool) -> Void)] = []

    @Test func openExternalLink() {
        let expectedURL = randomURL
        let sut = makeSUT()

        sut.openExternalLink(with: expectedURL)

        #expect(urlOpened == [expectedURL])
    }

    @Test func openExternalLink_withFallback_whenMainURLCompleteSuccessfully_shouldNotOpenFallback() {
        let sut = makeSUT()

        sut.openExternalLink(with: validURL, fallbackURL: fallbackURL)
        finishCompletion(at: 0, with: true)

        #expect(urlOpened.contains(fallbackURL) == false)
    }

    @Test func openExternalLink_withFallback_whenMainURLCompleteWithError_shouldOpenFallback() {
        let sut = makeSUT()

        sut.openExternalLink(with: validURL, fallbackURL: fallbackURL)
        finishCompletion(at: 0, with: false)

        #expect(urlOpened.contains(fallbackURL))
    }

    @Test func canOpenLink_withValidURL_shouldReturnTrue() {
        let sut = makeSUT()

        let result = sut.canOpenLink(with: validURL)

        #expect(result == true)
    }

    @Test func canOpenLink_withInvalidURL_shouldReturnFalse() {
        let sut = makeSUT()

        let result = sut.canOpenLink(with: invalidURL)

        #expect(result == false)
    }

    @Test func openExternalLinkFromExtension_shouldOpenURL() async {
        let expectedURL = randomURL
        let sut = makeSUT()

        sut.openExternalLinkFromExtension(url: expectedURL, from: await viewController())

        #expect(urlOpened == [expectedURL])
    }

    // MARK: - Test Helpers

    private func makeSUT() -> ExternalLinkOpener {
        ExternalLinkOpener(
            runInMainThread: { $0() },
            canOpenURL: canOpenURL,
            openURL: openURL,
            openURLWithCompletion: openURLWithCompletion,
            openURLFromViewController: openURLFromViewController
        )
    }

    private lazy var canOpenURL: (URL) -> Bool = { $0 == validURL }
    private lazy var openURL: (URL) -> Void = { self.urlOpened.append($0) }
    private lazy var openURLFromViewController: (URL, UIViewController) -> Void = { url, _ in
        self.urlOpened.append(url)
    }

    private lazy var openURLWithCompletion: (
        URL, @escaping (Bool) -> Void
    ) -> Void = { url, completion in
        self.urlOpened.append(url)
        self.completionHandlers.append(completion)
    }

    private func finishCompletion(at index: Int, with result: Bool) {
        completionHandlers[index](result)
    }
}

private var randomURL: URL { URL(string: "https://\(String.random())")! }
private var validURL: URL { URL(string: "https://valid")! }
private var fallbackURL: URL { URL(string: "https://fallbackURL")! }
private var invalidURL: URL { URL(string: "https://invalid")! }

private func viewController() async -> UIViewController {
    await MainActor.run {
        return UIViewController()
    }
}
