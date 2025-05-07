// Copyright © 2025 MEGA Limited. All rights reserved.

@preconcurrency import BackgroundTasks

public final class BackgroundTaskEntity: Sendable {
    public let bgTask: BGTask?

    public var expirationHandler: (() -> Void)? {
        get { bgTask?.expirationHandler }
        set { bgTask?.expirationHandler = newValue }
    }

    public init(bgTask: BGTask?) {
        self.bgTask = bgTask
    }

    public func setTaskCompleted(success: Bool) {
        bgTask?.setTaskCompleted(success: success)
    }
}
