// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAConnectivity
import MEGAInfrastructure
import MEGAPresentation
import MEGASdk
import MEGAAnalytics

public enum DependencyInjection {
    // MARK: - External Injection

    public static var sharedSdk: MEGASdk = .init()
    public static var keychainServiceName: String = "MEGASharedRepo"
    public static var keychainAccount: String = "keychain"
    public static var appGroup: String?
    public static var sceneType: SceneTypeEntity = .normal
    public static var emailFormatter: any EmailFormatUseCaseProtocol = DefaultEmailFormatter()
    public static var secondarySceneViewModel = SecondarySceneViewModel()
    public static var snackbarDisplayer: any SnackbarDisplaying = SnackbarDisplayer(viewModel: secondarySceneViewModel)
    public static var permanentCacheService: any CacheServiceProtocol = UserDefaultsCacheService()
    public static var fetchNodesEnabled = false
    public static var shouldIncludeFastLoginTimeout = false
    public static var updateDuplicateSessionForLogin = false

    public static var dataUsageLocalization: DataUsageScreenLocalization?

    // analyticsTracker is currently only set up from VPN app
    public static var analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    
    private static var loginUseCaseOverride: (any LoginUseCaseProtocol)?

    // MARK: - Internal Injection

    public static var keychainRepository: some KeychainRepositoryProtocol {
        KeychainRepository(serviceName: keychainServiceName, appGroup: appGroup)
    }

    public static var loginAPIRepository: some LoginAPIRepositoryProtocol {
        LoginAPIRepository(sdk: sharedSdk)
    }

    public static var loginStoreRepository: some LoginStoreRepositoryProtocol {
        LoginStoreRepository(
            keychainRepository: keychainRepository,
            keychainAccount: Self.keychainAccount)
    }

    public static var loginUseCase: any LoginUseCaseProtocol {
        get { loginUseCaseOverride ?? defaultLoginUseCase }
        set { loginUseCaseOverride = newValue }
    }

    public static var onboardingViewModel: OnboardingViewModel {
        OnboardingViewModel(
            loginUseCase: loginUseCase,
            analyticsTracker: analyticsTracker,
            permanentCacheService: permanentCacheService
        )
    }

    public static var connectionUseCase: some ConnectionUseCaseProtocol {
        MEGAConnectivity.DependencyInjection.singletonConnectionUseCase
    }

    public static var loginViewModel: LoginViewModel {
        LoginViewModel(
            sceneType: DependencyInjection.sceneType,
            loginUseCase: loginUseCase,
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
    }

    public static var dataUsageViewModel: DataUsageScreenViewModel {
        DataUsageScreenViewModel(
            localization: dataUsageLocalization,
            permanentCacheService: permanentCacheService
        )
    }

    public static var twoFactorAuthenticationViewModel: TwoFactorAuthenticationViewModel {
        // To give time for user to see the success state we wait for 500ms
        TwoFactorAuthenticationViewModel(
            analyticsTracker: analyticsTracker,
            sceneType: DependencyInjection.sceneType,
            delayAfterSuccess: 0.5
        )
    }
    
    public static var createAccountUseCase: some CreateAccountUseCaseProtocol {
        CreateAccountUseCase(repository: CreateAccountRepository(sdk: sharedSdk))
    }

    public static var createAccountViewModel: CreateAccountViewModel {
        CreateAccountViewModel(
            createAccountUseCase: createAccountUseCase,
            connectionUseCase: connectionUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
    }

    public static var accountConfirmationUseCase: some AccountConfirmationUseCaseProtocol {
        AccountConfirmationUseCase(repository: AccountConfirmationRepository(sdk: sharedSdk))
    }
        
    public static var appLoadingManager: some AppLoadingStateManagerProtocol {
        AppLoadingStateManager(viewModel: secondarySceneViewModel)
    }
    
    public static var createAccountEmailPresenter: some EmailPresenting {
        EmailPresenter(
            emailFormatUseCase: emailFormatter,
            externalLinkOpener: MEGAInfrastructure.DependencyInjection.externalLinkOpener,
            appLoadingManager: appLoadingManager
        )
    }

    public static func emailConfirmationViewModel(
        with information: NewAccountInformationEntity
    ) -> CreateAccountEmailSentViewModel {
        CreateAccountEmailSentViewModel(
            information: information,
            accountConfirmationUseCase: accountConfirmationUseCase,
            loginUseCase: loginUseCase,
            snackbarDisplayer: snackbarDisplayer,
            analyticsTracker: analyticsTracker
        )
    }

    public static func changeEmailViewModel(
        name: String,
        email: String
    ) -> ChangeEmailViewModel {
        ChangeEmailViewModel(
            name: name,
            email: email,
            accountConfirmationUseCase: accountConfirmationUseCase
        )
    }
    
    public static var passwordStrengthMeasurer: some PasswordStrengthMeasuring {
        PasswordStrengthMeasurer(sdk: sharedSdk)
    }

    public static var newPasswordUseCase: some NewPasswordUseCaseProtocol {
        NewPasswordUseCase(passwordStrengthMeasurer: passwordStrengthMeasurer)
    }

    public static var newPasswordFieldViewModel: NewPasswordFieldViewModel {
        NewPasswordFieldViewModel(newPasswordUseCase: newPasswordUseCase)
    }

    public static func emailSentViewModel(with configuration: some EmailSentConfigurable) -> EmailSentViewModel {
        EmailSentViewModel(
            configuration: configuration,
            analyticsTracker: analyticsTracker,
            supportEmailPresenter: createAccountEmailPresenter
        )
    }

    public static var hasSetupDataUsageNotice: Bool {
        dataUsageLocalization != nil
    }
    
    private static var defaultLoginUseCase: some LoginUseCaseProtocol {
        LoginUseCase(
            fetchNodesEnabled: Self.fetchNodesEnabled,
            shouldIncludeFastLoginTimeout: Self.shouldIncludeFastLoginTimeout,
            updateDuplicateSession: Self.updateDuplicateSessionForLogin,
            loginAPIRepository: loginAPIRepository,
            loginStoreRepository: loginStoreRepository
        )
    }
}
