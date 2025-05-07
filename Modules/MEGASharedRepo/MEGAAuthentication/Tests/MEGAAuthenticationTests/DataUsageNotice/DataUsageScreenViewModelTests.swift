// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Foundation
import MEGAInfrastructure
import MEGAInfrastructureMocks
import Testing

struct DataUsageScreenViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.route == nil)
    }

    @Test func didTapCloseButton_shouldRouteToDismissed() {
        let sut = makeSUT()

        sut.didTapCloseButton()

        #expect(sut.route == .dismissed)
    }

    @Test func didTapAgreeButton_shouldSaveToCache_andRouteToAgreed() {
        let mockCacheService = MockCacheService()
        let sut = makeSUT(permanentCacheService: mockCacheService)

        sut.didTapAgreeButton()

        mockCacheService.swt.assertActions(
            shouldBe: [.save(.init(
                object: true,
                key: DataUsageScreenViewModel.dataUsageCacheKey
            ))]
        )
        #expect(sut.route == .agreed)
    }

    struct StringInjectionArguments {
        let localization: DataUsageScreenLocalization?
        let expectedTitle: String
        let expectedSubtitle: AttributedString
        let expectedButtonTitle: String
    }

    @Test(
        arguments: [
            StringInjectionArguments(
                localization: nil,
                expectedTitle: "",
                expectedSubtitle: "",
                expectedButtonTitle: ""
            ),
            StringInjectionArguments(
                localization: .init(
                    title: "title" ,
                    subtitle: "subtitle",
                    agreeButtonTitle: "button"
                ),
                expectedTitle: "title",
                expectedSubtitle: "subtitle",
                expectedButtonTitle: "button"
            ),
            StringInjectionArguments(
                localization: .init(
                    title: "anotherTitle" ,
                    subtitle: "anotherSubtitle",
                    agreeButtonTitle: "anotherButton"
                ),
                expectedTitle: "anotherTitle",
                expectedSubtitle: "anotherSubtitle",
                expectedButtonTitle: "anotherButton"
            )
        ]
    ) func title(arguments: StringInjectionArguments) {
        let sut = makeSUT(localization: arguments.localization)

        #expect(sut.title == arguments.expectedTitle)
        #expect(sut.subtitle == arguments.expectedSubtitle)
        #expect(sut.buttonTitle == arguments.expectedButtonTitle)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        localization: DataUsageScreenLocalization? = nil,
        permanentCacheService: some CacheServiceProtocol = MockCacheService()
    ) -> DataUsageScreenViewModel {
        DataUsageScreenViewModel(
            localization: localization,
            permanentCacheService: permanentCacheService
        )
    }
}
