// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGADebugLogger
import MEGAPreference
import MEGATest
import Testing

struct DebugModeUseCaseTests {
    struct ToggleDebugModeArguments {
        let isEnabledPreference: Bool
        let expectedToggle: Bool
    }

    @Test(
        arguments: [
            ToggleDebugModeArguments(
                isEnabledPreference: true,
                expectedToggle: false
            ),
            ToggleDebugModeArguments(
                isEnabledPreference: false,
                expectedToggle: true
            )
        ]
    ) func toggleDebugMode_shouldTogglePreference_andInRepository(
        arguments: ToggleDebugModeArguments
    ) {
        let mockUseCase = MockPreferenceUseCase(dict: [
            PreferenceKeyEntity.debugMode.rawValue: arguments.isEnabledPreference
        ])
        let sut = makeSUT(preferenceUseCase: mockUseCase)

        sut.toggleDebugMode()

        #expect(
            mockUseCase.dict[PreferenceKeyEntity.debugMode.rawValue] as? Bool ==
            arguments.expectedToggle
        )
    }

    @Test func observeDebugMode() {
        let sut = makeSUT(
            preferenceUseCase: MockPreferenceUseCase(
                dict: [PreferenceKeyEntity.debugMode.rawValue: true]
            )
        )

        let spy = sut.observeDebugMode().spy()

        sut.toggleDebugMode()
        sut.toggleDebugMode()
        sut.toggleDebugMode()

        #expect(spy.values == [true, false, true, false])
    }

    // MARK: - Helpers

    private func makeSUT(
        preferenceUseCase: some PreferenceUseCaseProtocol = MockPreferenceUseCase()
    ) -> DebugModeUseCase {
        DebugModeUseCase(preferenceUseCase: preferenceUseCase)
    }
}
