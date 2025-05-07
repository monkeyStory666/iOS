import MEGAAccountManagement
import MEGAAnalytics
import MEGAInfrastructure
import MEGAConnectivity
import MEGAPresentation
import MEGASDKRepo

public enum DependencyInjection {
    // MARK: - External Injection

    // analyticsTracker is currently only set up from VPN app
    public static var analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    public static var supportEmailPresenter: (any EmailPresenting)?
    public static var recoveryKeyDisclaimer: String?
    public static var clientDetailsSection: DeleteAccountDetailsSectionViewModel?
    public static var secondarySceneViewModel = SecondarySceneViewModel()
    public static var snackbarDisplayer: any SnackbarDisplaying = SnackbarDisplayer(viewModel: secondarySceneViewModel)
    public static var featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = FeatureFlagsUseCase(
        repo: FeatureFlagsRepository(cacheService: UserDefaultsCacheService())
    )
    public static var changeSDKEnvironmentUseCase: any ChangeSDKEnvironmentUseCaseProtocol = ChangeSDKEnvironmentUseCase(
        repository: ChangeSDKEnvironmentRepository(sdk: .init())
    )

    // MARK: - Internal Injection

    public static var connectionUseCase: some ConnectionUseCaseProtocol {
        MEGAConnectivity.DependencyInjection.singletonConnectionUseCase
    }

    public static var appInformation: AppInformation {
        AppInformation()
    }
}
