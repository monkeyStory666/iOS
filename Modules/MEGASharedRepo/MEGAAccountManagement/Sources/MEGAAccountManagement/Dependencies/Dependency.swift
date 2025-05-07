// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAAuthentication
import MEGAInfrastructure
import MEGAPresentation
import MEGASdk
import UIKit

public enum DependencyInjection {
    // MARK: - External Injection
    
    public static var sharedSdk: MEGASdk = .init()
    public static var snackbarDisplayer: any SnackbarDisplaying = SnackbarDisplayer(viewModel: SecondarySceneViewModel())
    public static var cacheService: any CacheServiceProtocol = UserDefaultsCacheService()
    public static var permanentCacheService: any CacheServiceProtocol = UserDefaultsCacheService(
        userDefaults: UserDefaults(suiteName: "permanent.cache")!
    )
    public static var refreshUserDataUseCase: any RefreshUserDataNotificationUseCaseProtocol = RefreshUserDataUseCase()
    public static var passwordReminderUseLocalCache = false
    public static var prioritizeVPNFeature = false
    public static var shouldShowCancelSurvey = true

    // analyticsTracker is currently only set up from VPN app
    public static var analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    // MARK: - Internal injection
    
    public static var deleteAccountUseCase: some DeleteAccountUseCaseProtocol {
        DeleteAccountUseCase(
            repository: DeleteAccountRepository(sdk: sharedSdk),
            logoutPollingPublisher: {
                Timer // Timer to poll test auto-logout every 30 seconds
                    .publish(every: TimeInterval(30), on: .current, in: .default)
                    .autoconnect()
                    .eraseToAnyPublisher()
            }()
        )
    }
    
    public static var fetchAccountUseCase: some FetchAccountUseCaseProtocol {
        FetchAccountUseCase(
            fetcher: RepositoryFetcher(
                remoteRepository: RemoteAccountRepository(sdk: sharedSdk),
                localRepository: LocalDataRepository(
                    key: "accountEntity",
                    cacheService: cacheService
                )
            )
        )
    }

    public static var fetchAccountPlanUseCase: some FetchAccountPlanUseCaseProtocol {
        FetchAccountPlanUseCase(
            fetcher: RepositoryFetcher(
                remoteRepository: RemoteAccountDetailsRepository(sdk: sharedSdk),
                localRepository: LocalDataRepository(
                    key: "accountDetails",
                    cacheService: cacheService
                )
            )
        )
    }

    public static var fetchUIImageAvatarUseCase: some FetchUIImageAvatarUseCaseProtocol {
        FetchUIImageAvatarUseCase(fetchAvatarUseCase: FetchAvatarUseCase(
            repository: UserAvatarRepository(
                sdk: sharedSdk,
                getDataFromPath: { path in
                    try Data(contentsOf: URL(fileURLWithPath: path))
                }),
            fileSystemRepository: FileSystemRepository(fileManager: .default),
            fetchAccountUseCase: fetchAccountUseCase,
            imageFromData: UIImage.init(data:)
        ))
    }
    
    public static var generateDefaultAvatarUseCase: some GenerateDefaultAvatarUseCaseProtocol {
        GenerateDefaultAvatarUseCase(
            generator: DefaultAvatarGenerator(),
            languageDetector: RightToLeftLanguageDetector(),
            fetchAccountUseCase: fetchAccountUseCase,
            backgroundColorRepo: DefaultAvatarBackgroundColorRepository(sdk: sharedSdk)
        )
    }
    
    public static var changeNameUseCase: some ChangeNameUseCaseProtocol {
        ChangeNameUseCase(accountNameRepository: AccountNameRepository(sdk: sharedSdk))
    }
    
    public static var changePasswordUseCase: some ChangePasswordUseCaseProtocol {
        ChangePasswordUseCase(
            passwordRepository: PasswordRepository(sdk: sharedSdk),
            passwordTester: TestPasswordRepository(sdk: sharedSdk)
        )
    }
    
    public static var passwordReminderUseCase: any PasswordReminderUseCaseProtocol {
        PasswordReminderUseCase(
            repository: PasswordReminderRepository(sdk: sharedSdk),
            cacheService: permanentCacheService,
            accountUseCase: fetchAccountUseCase,
            useLocalCache: passwordReminderUseLocalCache
        )
    }
    
    public static var recoveryKeyUseCase: some RecoveryKeyUseCaseProtocol {
        RecoveryKeyUseCase(repository: RecoveryKeyRepository(sdk: sharedSdk))
    }
    
    public static var testPasswordUseCase: some TestPasswordUseCaseProtocol {
        TestPasswordUseCase(tester: TestPasswordRepository(sdk: sharedSdk))
    }

    public static var copyToClipboard: some CopyToClipboardProtocol {
        CopyToClipboard(
            setValue: UIPasteboard.general.setValue,
            setString: { UIPasteboard.general.string = $0 }
        )
    }

    public static var textFileFromString: some TextFileFromStringProtocol {
        TextFileFromString()
    }

    public static func makeDeleteAccountDetailsViewModel(
        with sections: [DeleteAccountDetailsSectionViewModel]
    ) -> DeleteAccountDetailsViewModel {
        DeleteAccountDetailsViewModel(sections: sections)
    }

    public static var recoveryKeyViewModel: RecoveryKeyViewModel {
        RecoveryKeyViewModel(
            snackbarDisplayer: snackbarDisplayer,
            copyToClipboard: copyToClipboard,
            textFileFromString: textFileFromString,
            recoveryKeyUseCase: recoveryKeyUseCase,
            analyticsTracker: analyticsTracker
        )
    }

    public static var testPasswordViewModel: TestPasswordViewModel {
        TestPasswordViewModel(
            testPasswordUseCase: testPasswordUseCase,
            analyticsTracker: analyticsTracker
        )
    }
}
