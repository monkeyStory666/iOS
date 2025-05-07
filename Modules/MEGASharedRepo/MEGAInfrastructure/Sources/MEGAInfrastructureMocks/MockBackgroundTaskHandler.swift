// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGATest

public final class MockBackgroundTaskUseCase:
    MockObject<MockBackgroundTaskUseCase.Action>,
    BackgroundTaskUseCaseProtocol {
    public enum Action {
        case registerBackgroundTask(
            identifier: String,
            queue: BackgroundTaskQueue,
            operation: BackgroundTaskOperation
        )
        case scheduleBackgroundTask(identifier: String, earliestBeginDate: Date?)
        case ongoingBackgroundTask(identifier: String)
        case cancelBackgroundTask(identifier: String)
        case prepareForegroundTasks
    }

    public var _ongoingBackgroundTask: Date?

    public init(ongoingBackgroundTask: Date? = nil) {
        _ongoingBackgroundTask = ongoingBackgroundTask
    }

    public func registerBackgroundTask(
        identifier: String,
        queue: BackgroundTaskQueue,
        operation: BackgroundTaskOperation
    ) {
        actions.append(.registerBackgroundTask(identifier: identifier, queue: queue, operation: operation))
    }

    public func scheduleBackgroundTask(
        identifier: String,
        earliestBeginDate: Date?
    ) throws {
        actions.append(.scheduleBackgroundTask(identifier: identifier, earliestBeginDate: earliestBeginDate))
    }

    public func ongoingBackgroundTask(with identifier: String) async -> Date? {
        actions.append(.ongoingBackgroundTask(identifier: identifier))
        return _ongoingBackgroundTask
    }

    public func cancelBackgroundTask(withIdentifier identifier: String) {
        actions.append(.cancelBackgroundTask(identifier: identifier))
    }

    public func prepareForegroundTasksForExistingBackgroundTasks() {
        actions.append(.prepareForegroundTasks)
    }
}

extension MockBackgroundTaskUseCase.Action: Equatable {
    public static func == (lhs: MockBackgroundTaskUseCase.Action, rhs: MockBackgroundTaskUseCase.Action) -> Bool {
        switch (lhs, rhs) {
        case let (.registerBackgroundTask(lhsId, lhsQueue, _), .registerBackgroundTask(rhsId, rhsQueue, _)):
            return lhsId == rhsId && lhsQueue == rhsQueue
        case let (.scheduleBackgroundTask(lhsId, lhsDate), .scheduleBackgroundTask(rhsId, rhsDate)):
            return lhsId == rhsId && lhsDate == rhsDate
        case let (.ongoingBackgroundTask(lhsId), .ongoingBackgroundTask(rhsId)):
            return lhsId == rhsId
        case let (.cancelBackgroundTask(lhsId), .cancelBackgroundTask(rhsId)):
            return lhsId == rhsId
        case (.prepareForegroundTasks, .prepareForegroundTasks):
            return true
        default:
            return false
        }
    }
}

extension BackgroundTaskQueue: Equatable {
    public static func == (lhs: BackgroundTaskQueue, rhs: BackgroundTaskQueue) -> Bool {
        switch (lhs, rhs) {
        case (.main, .main):
            return true
        case let (.global(lhsQos), .global(rhsQos)):
            return lhsQos == rhsQos
        default:
            return false
        }
    }
}
