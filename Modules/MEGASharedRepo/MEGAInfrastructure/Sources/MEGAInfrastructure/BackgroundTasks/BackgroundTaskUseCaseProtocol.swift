// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation

/// This use case is responsible for managing background tasks.
///
/// To use this use case, make sure to setup the proper signing and capabilities
/// of the app to support background tasks.
///
/// Check out this Apple documentation for more information:
/// https://developer.apple.com/documentation/backgroundtasks
/// https://developer.apple.com/documentation/uikit/using-background-tasks-to-update-your-app
public protocol BackgroundTaskUseCaseProtocol {
    func registerBackgroundTask(
        identifier: String,
        queue: BackgroundTaskQueue,
        operation: BackgroundTaskOperation
    )

    func scheduleBackgroundTask(
        identifier: String,
        earliestBeginDate: Date?
    ) throws

    func ongoingBackgroundTask(with identifier: String) async -> Date?
    func cancelBackgroundTask(withIdentifier identifier: String)

    /// This is needed so that if the app is inactive or restarted after scheduling the background task
    /// we can still sync those tasks into foreground tasks to enhance the reliability and accuracy
    /// of the execution when the app is in foreground
    ///
    /// Only call this after registering all background tasks that should be synced into foreground tasks.
    func prepareForegroundTasksForExistingBackgroundTasks()
}
