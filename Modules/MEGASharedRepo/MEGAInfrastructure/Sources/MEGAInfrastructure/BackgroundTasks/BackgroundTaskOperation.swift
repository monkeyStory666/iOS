// Copyright © 2025 MEGA Limited. All rights reserved.

public struct BackgroundTaskOperation {
    public let task: (_ completionHandler: () -> Void) async -> Void
    public let onTaskCanceled: (() -> Void)?

    public init(
        task: @escaping (_ completionHandler: () -> Void) async -> Void,
        onTaskCanceled: (() -> Void)? = nil
    ) {
        self.task = task
        self.onTaskCanceled = onTaskCanceled
    }
}
