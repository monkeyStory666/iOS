// Copyright © 2025 MEGA Limited. All rights reserved.

import BackgroundTasks
import Combine
import Foundation
import MEGASwift

public final class BackgroundTaskUseCase: BackgroundTaskUseCaseProtocol {
    @Atomic private var scheduleCancellables: [String: AnyCancellable] = [:]
    @Atomic private var operations: [String: BackgroundTaskOperation] = [:]

    private(set) var backgroundOperationTask: Task<Void, Never>?
    private(set) var foregroundOperationTask: Task<Void, Never>?

    private let bgTaskScheduler: any BackgroundTaskScheduling
    private let timer: AnyPublisher<Date, Never>

    public init(
        bgTaskScheduler: some BackgroundTaskScheduling,
        timer: AnyPublisher<Date, Never>
    ) {
        self.bgTaskScheduler = bgTaskScheduler
        self.timer = timer
    }

    public func registerBackgroundTask(
        identifier: String,
        queue: BackgroundTaskQueue,
        operation: BackgroundTaskOperation
    ) {
        $operations.mutate { $0[identifier] = operation }
        bgTaskScheduler.register(
            forTaskWithIdentifier: identifier,
            using: queue.toDispatchQueueType
        ) { task in
            task.expirationHandler = { operation.onTaskCanceled?() }

            self.backgroundOperationTask = Task {
                await operation.task { task.setTaskCompleted(success: true) }
            }
        }
    }

    public func scheduleBackgroundTask(
        identifier: String,
        earliestBeginDate: Date?
    ) throws {
        scheduleForegroundTask(
            identifier: identifier,
            earliestBeginDate: earliestBeginDate
        )
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate
        try bgTaskScheduler.submit(request)
    }

    /// On top of the background task, we also sync those tasks into foreground tasks with a timer
    /// to ensure the reliability and accuracy of the execution when the app is in foreground.
    private func scheduleForegroundTask(
        identifier: String,
        earliestBeginDate: Date?
    ) {
        let cancellable = timer.sink { [weak self] now in
            guard
                let earliestBeginDate,
                now >= earliestBeginDate,
                let operation = self?.operations[identifier]
            else { return }

            self?.foregroundOperationTask = Task {
                await operation.task {
                    self?.cancelBackgroundTask(withIdentifier: identifier)
                    self?.cancelForegroundTask(withIdentifier: identifier)
                }
            }
        }
        scheduleCancellables[identifier]?.cancel()
        $scheduleCancellables.mutate { $0[identifier] = cancellable }
    }

    public func ongoingBackgroundTask(with identifier: String) async -> Date? {
        await bgTaskScheduler.pendingTaskRequests()
            .first(where: { $0.identifier == identifier })?
            .earliestBeginDate
    }

    public func cancelBackgroundTask(withIdentifier identifier: String) {
        bgTaskScheduler.cancel(taskRequestWithIdentifier: identifier)
        backgroundOperationTask?.cancel()
        backgroundOperationTask = nil
    }

    public func prepareForegroundTasksForExistingBackgroundTasks() {
        bgTaskScheduler.getPendingTaskRequests { [weak self] bgTaskRequests in
            for bgTaskRequest in bgTaskRequests {
                self?.scheduleForegroundTask(
                    identifier: bgTaskRequest.identifier,
                    earliestBeginDate: bgTaskRequest.earliestBeginDate
                )
            }
        }
    }

    private func cancelForegroundTask(withIdentifier identifier: String) {
        scheduleCancellables[identifier]?.cancel()
        $scheduleCancellables.mutate { $0[identifier] = nil }
        foregroundOperationTask?.cancel()
        foregroundOperationTask = nil
    }
}

extension BackgroundTaskQueue {
    var toDispatchQueueType: dispatch_queue_t {
        switch self {
        case .main: .main
        case .global(let qos): .global(qos: qos)
        }
    }
}
