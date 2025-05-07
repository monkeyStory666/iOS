// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAInfrastructure
import MEGALogger
import MEGAPreference
import MEGAPresentation
import MEGASdk

public enum DependencyInjection {
    // MARK: - External Injection

    public static var userDefaults: UserDefaults = UserDefaults.standard
    public static var snackbarDisplayer: SnackbarDisplaying = SnackbarDisplayer(viewModel: .init())
    public static var supportEmailFormatUseCase: EmailFormatUseCaseProtocol?
    public static var emailPresenter: EmailPresenting?
    public static var analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?

    public static var sharedLogsViewModel: ShareLogsViewModel {
        .init(loggingUseCase: loggingUseCase)
    }

    public static var logsViewerViewModel: LogsViewerScreenViewModel {
        LogsViewerScreenViewModel(
            loggingUseCase: loggingUseCase,
            stringFromLink: { try? String(contentsOf: $0, encoding: .utf8) }
        )
    }

    public static var loggingUseCase: some LoggingUseCaseProtocol {
        MEGALogger.DependencyInjection.loggingUseCase
    }

    public static var emailFormatUseCase: EmailFormatUseCaseProtocol? {
        guard let supportEmailFormatUseCase else { return nil }

        return DebugLogAttachmentEmailUseCase(
            supportEmailFormatUseCase: supportEmailFormatUseCase,
            loggingUseCase: loggingUseCase,
            dataContentsOfURL: { try Data(contentsOf: $0) }
        )
    }

    private nonisolated(unsafe) static var singletonDebugModeUseCase: some DebugModeUseCaseProtocol = {
        DebugModeUseCase(preferenceUseCase: preferenceUseCase)
    }()

    public static var debugModeUseCase: some DebugModeUseCaseProtocol {
        singletonDebugModeUseCase
    }

    public static var preferenceRepository: some PreferenceRepositoryProtocol {
        PreferenceRepository(userDefaults: userDefaults)
    }

    public static var preferenceUseCase: some PreferenceUseCaseProtocol {
        PreferenceUseCase(repository: preferenceRepository)
    }
}

