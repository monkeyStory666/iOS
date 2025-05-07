import MEGAInfrastructure
import MEGASdk

public enum DependencyInjection {
    // MARK: - External Injection

    public static var sharedSdk: MEGASdk = .init()

    // MARK: - Internal Injection

    public static var checkAnalyticsEnabledUseCase: some CheckAnalyticsEnabledUseCaseProtocol {
        CheckAnalyticsEnabledUseCase(
            appEnvironmentUseCase: appEnvironmentUseCase
        )
    }

    static var appEnvironmentUseCase: some AppEnvironmentUseCaseProtocol {
        AppEnvironmentUseCase.shared
    }
}
