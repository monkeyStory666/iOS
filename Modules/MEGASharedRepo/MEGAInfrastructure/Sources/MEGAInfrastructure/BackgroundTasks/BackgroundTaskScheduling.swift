// Copyright © 2025 MEGA Limited. All rights reserved.

import BackgroundTasks
import Foundation

public protocol BackgroundTaskScheduling {
    @discardableResult
    func register(
        forTaskWithIdentifier identifier: String,
        using queue: dispatch_queue_t?,
        launchHandler: @escaping (BackgroundTaskEntity) -> Void
    ) -> Bool
    func submit(_ taskRequest: BGTaskRequest) throws
    func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void)
    func pendingTaskRequests() async -> [BGTaskRequest]
    func cancel(taskRequestWithIdentifier identifier: String)
}

extension BGTaskScheduler: BackgroundTaskScheduling {
    @discardableResult
    public func register(
        forTaskWithIdentifier identifier: String,
        using queue: dispatch_queue_t?,
        launchHandler: @escaping (BackgroundTaskEntity) -> Void
    ) -> Bool {
        register(
            forTaskWithIdentifier: identifier,
            using: queue,
            launchHandler: { launchHandler(BackgroundTaskEntity(bgTask: $0)) }
        )
    }
}
