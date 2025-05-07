// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest
import BackgroundTasks

public final class MockBackgroundTaskScheduler:
    MockObject<MockBackgroundTaskScheduler.Action>,
    BackgroundTaskScheduling {

    public enum Action: Equatable {
        case register(identifier: String, queue: dispatch_queue_t?)
        case submit(BGTaskRequest)
        case getPendingTaskRequests
        case pendingTaskRequests
        case cancel(identifier: String)
    }

    public var _register: Bool
    public var _submit: Result<Void, Error>
    public var _pendingTaskRequests: [BGTaskRequest]

    public init(
        register: Bool = true,
        submit: Result<Void, Error> = .success(()),
        pendingTaskRequests: [BGTaskRequest] = []
    ) {
        _register = register
        _submit = submit
        _pendingTaskRequests = pendingTaskRequests
    }

    @discardableResult
    public func register(
        forTaskWithIdentifier identifier: String,
        using queue: dispatch_queue_t?,
        launchHandler: @escaping (BackgroundTaskEntity) -> Void
    ) -> Bool {
        actions.append(.register(identifier: identifier, queue: queue))
        return _register
    }

    public func submit(_ taskRequest: BGTaskRequest) throws {
        actions.append(.submit(taskRequest))
        try _submit.get()
    }

    public func getPendingTaskRequests(
        completionHandler: @escaping ([BGTaskRequest]) -> Void
    ) {
        actions.append(.getPendingTaskRequests)
        completionHandler(_pendingTaskRequests)
    }

    public func pendingTaskRequests() async -> [BGTaskRequest] {
        actions.append(.pendingTaskRequests)
        return _pendingTaskRequests
    }

    public func cancel(taskRequestWithIdentifier identifier: String) {
        actions.append(.cancel(identifier: identifier))
    }
}
