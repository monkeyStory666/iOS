// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGASdk

public enum DependencyInjection {
    // MARK: - External Injection

    public nonisolated(unsafe) static var sharedSdk: MEGASdk = .init()
    public nonisolated(unsafe) static var diagnosticMessage: (() async -> String)?
    public nonisolated(unsafe) static var isDebugModePublisher: AnyPublisher<Bool, Never> = {
        Just(false).eraseToAnyPublisher()
    }()

    // Defines the log file path (e.g., `clientAppName/Logs`) and adds the client app name to the logs
    public nonisolated(unsafe) static var clientAppName = "MEGASharedRepo"

    public static var loggingRepository: LoggingRepository {
        .init(
            sdk: sharedSdk,
            diagnosticMessage: diagnosticMessage
        )
    }

    private nonisolated(unsafe) static var singletonLoggingUseCase: some LoggingUseCaseProtocol = {
        LoggingUseCase(
            repository: loggingRepository,
            isDebugModePublisher: isDebugModePublisher
        )
    }()

    public static var loggingUseCase: some LoggingUseCaseProtocol {
        singletonLoggingUseCase
    }
}
