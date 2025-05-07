// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAInfrastructure
import MEGAInfrastructureMocks
import XCTest

final class CheckAnalyticsEnabledUseCaseTests: XCTestCase {
    func testIsAnalyticsEnabled_shouldOnlyBeEnabledInProduction() {
        func assert(
            whenConfiguration configuration: AppConfigurationEntity,
            shouldEnableAnalytics: Bool,
            line: UInt = #line
        ) {
            let sut = makeSUT(
                appEnvironmentUseCase: MockAppEnvironmentUseCase(
                    configuration: configuration
                )
            )

            XCTAssertEqual(
                sut.isAnalyticsEnabled(),
                shouldEnableAnalytics,
                line: line
            )
        }

        assert(whenConfiguration: .debug, shouldEnableAnalytics: false)
        assert(whenConfiguration: .qa, shouldEnableAnalytics: false)
        assert(whenConfiguration: .testFlight, shouldEnableAnalytics: false)
        assert(whenConfiguration: .production, shouldEnableAnalytics: true)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        appEnvironmentUseCase: some AppEnvironmentUseCaseProtocol = MockAppEnvironmentUseCase(),
        line: UInt = #line
    ) -> CheckAnalyticsEnabledUseCase {
        CheckAnalyticsEnabledUseCase(
            appEnvironmentUseCase: appEnvironmentUseCase
        )
    }
}
