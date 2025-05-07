// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGASettings
import MEGAPresentation
import MEGAPresentationMocks
import XCTest

final class SettingsListSupportRowViewModelTests: XCTestCase {
    func testDidTapRow_shouldPresentMailCompose() async {
        let mockEmailPresenter = MockEmailPresenter()
        let sut = makeSUT(emailPresenter: mockEmailPresenter)

        await sut.didTapRow()

        mockEmailPresenter.assertActions(shouldBe: [.presentMailCompose])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        emailPresenter: some EmailPresenting = MockEmailPresenter(),
        file: StaticString = #file, line: UInt = #line
    ) -> SettingsListSupportRowViewModel {
        let sut = SettingsListSupportRowViewModel(emailPresenter: emailPresenter)
        trackForMemoryLeaks(on: sut, file: file, line: line)
        return sut
    }
}
