// Copyright © 2024 MEGA Limited. All rights reserved.

import BackgroundTasks
import Foundation
import MEGASdk
import MEGASwift
import UIKit

public enum DependencyInjection {
    // MARK: - External Injection

    public static var sharedSdk: MEGASdk = .init()

    // MARK: - Internal Injection

    public static var singletonBackgroundTaskUseCase: some BackgroundTaskUseCaseProtocol = {
        BackgroundTaskUseCase(
            bgTaskScheduler: {
                #if targetEnvironment(macCatalyst)
                BackgroundTaskSchedulerMac()
                #else
                BGTaskScheduler.shared
                #endif
            }(),
            timer: {
                Timer.publish(every: 1, tolerance: 1, on: .main, in: .common)
                    .autoconnect()
                    .eraseToAnyPublisher()
            }()
        )
    }()

    public static var externalLinkOpener: ExternalLinkOpening {
        ExternalLinkOpener(
            runInMainThread: { action in
                DispatchQueue.main.async {
                    action()
                }
            },
            canOpenURL: UIApplication.shared.canOpenURL,
            openURL: { UIApplication.shared.open($0) },
            openURLWithCompletion: { UIApplication.shared.open($0, completionHandler: $1) },
            openURLFromViewController: { url, viewController in
                // 'UIApplication.shared' is unavailable in application extensions for iOS
                // Use view controller based solutions to open URLs in extensions.

                // Create a sequence starting with `viewController` and iterating through the responder chain.
                let application = sequence(first: viewController, next: { $0.next })
                    .compactMap { $0 as? UIApplication }
                    .first
                application?.open(url)
            }
        )
    }

    public static var deviceInformation: DeviceInformation {
        DeviceInformation()
    }

    public static var remoteFeatureFlagRepository: RemoteFeatureFlagRepositoryProtocol {
        RemoteFeatureFlagRepository(
            megaSdk: sharedSdk,
            withAsyncThrowingValueWithTimeout: { timeout, action in
                try await withAsyncThrowingValue(timeout: timeout, in: action)
            },
            runInUserInitiatedTask: { operation in
                Task<Void, Never>(priority: .userInitiated, operation: operation)
            }
        )
    }
}

// MARK: - Deprecated Dependency

public extension RemoteFeatureFlagRepository {
    @available(
        *,
         deprecated,
         message: "Use DependencyInjection.remoteFeatureFlagRepository instead"
    )
    init(sdk: MEGASdk) {
        self.init(
            megaSdk: sdk,
            withAsyncThrowingValueWithTimeout: { timeout, action in
                try await withAsyncThrowingValue(timeout: timeout, in: action)
            },
            runInUserInitiatedTask: { operation in
                Task<Void, Never>(priority: .userInitiated, operation: operation)
            }
        )
    }
}
