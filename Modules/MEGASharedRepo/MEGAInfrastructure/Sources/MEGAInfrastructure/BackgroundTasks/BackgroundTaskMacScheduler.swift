// Copyright © 2025 MEGA Limited. All rights reserved.

import BackgroundTasks
import Foundation
import MEGASwift

#if targetEnvironment(macCatalyst)
public final class BackgroundTaskSchedulerMac: BackgroundTaskScheduling, @unchecked Sendable {
    @Atomic private var pendingRequests: [String: BGTaskRequest] = [:]

    @discardableResult
    public func register(
        forTaskWithIdentifier identifier: String,
        using queue: dispatch_queue_t? = nil,
        launchHandler: @escaping (BackgroundTaskEntity) -> Void
    ) -> Bool {
        return true
    }

    public func submit(_ taskRequest: BGTaskRequest) throws {
        $pendingRequests.mutate { $0[taskRequest.identifier] = taskRequest }
    }

    public func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void) {
        completionHandler(Array(pendingRequests.values))
    }

    public func pendingTaskRequests() async -> [BGTaskRequest] {
        await withCheckedContinuation { continuation in
            self.getPendingTaskRequests { tasks in
                continuation.resume(returning: tasks)
            }
        }
    }

    public func cancel(taskRequestWithIdentifier identifier: String) {
        $pendingRequests.mutate { $0.removeValue(forKey: identifier) }
    }
}
#endif
