// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import Testing

@Suite(.serialized)
final class AppEnvironmentUseCaseTests {
    deinit {
        makeSUT().config(.production)
    }

    @Test func initialConfiguration() {
        #expect(makeSUT().configuration == .production)
    }

    @Test(
        arguments: [
            AppConfigurationEntity.debug,
            AppConfigurationEntity.qa,
            AppConfigurationEntity.testFlight,
            AppConfigurationEntity.production
        ]
    ) func configShouldSetConfiguration(
        configuration: AppConfigurationEntity
    ) {
        let sut = makeSUT()

        sut.config(configuration)

        #expect(sut.configuration == configuration)
    }

    // MARK: - Test Helpers

    private func makeSUT() -> AppEnvironmentUseCase {
        AppEnvironmentUseCase.shared
    }
}
