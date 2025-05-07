// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGAInfrastructure
@testable import MEGAInfrastructureMocks
import BackgroundTasks
import Combine
import Foundation
import Testing

struct BackgroundTaskUseCaseTests {
    private let timerSubject = PassthroughSubject<Date, Never>()

    struct RegisterBackgroundTaskArguments: @unchecked Sendable {
        let identifier: String
        let queue: BackgroundTaskQueue
        let expectedQueueType: dispatch_queue_t
    }

    @Test(
        arguments: [
            RegisterBackgroundTaskArguments(
                identifier: .random(),
                queue: .main,
                expectedQueueType: .main
            ),
            RegisterBackgroundTaskArguments(
                identifier: .random(),
                queue: .global(qos: .userInitiated),
                expectedQueueType: .global(qos: .userInitiated)
            ),
            RegisterBackgroundTaskArguments(
                identifier: .random(),
                queue: .global(qos: .background),
                expectedQueueType: .global(qos: .background)
            )
        ]
    ) func registerBackgroundTask_shouldRegisterTask(
        args: RegisterBackgroundTaskArguments
    ) {
        let mockScheduler = MockBackgroundTaskScheduler()
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        sut.registerBackgroundTask(
            identifier: args.identifier,
            queue: args.queue,
            operation: .sample
        )

        mockScheduler.swt.assertActions(
            shouldBe: [
                .register(
                    identifier: args.identifier,
                    queue: args.expectedQueueType
                )
            ]
        )
    }

    @Test func scheduleBackgroundTask_shouldScheduleTask() throws {
        let expectedIdentifier = String.random()
        let expectedDate = Date()
        let mockScheduler = MockBackgroundTaskScheduler()
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        try sut.scheduleBackgroundTask(
            identifier: expectedIdentifier,
            earliestBeginDate: expectedDate
        )

        #expect(mockScheduler.actions.count == 1)

        if case .submit(let request) = mockScheduler.actions.first {
            #expect(request.identifier == expectedIdentifier)
            #expect(request.earliestBeginDate == expectedDate)
        } else {
            Issue.record("Expected to submit BGTaskRequest")
        }
    }

    @Test func ongoingBackgroundTask_shouldReturnPendingTaskRequests_withCorrectIdentifiers() async {
        let expectedIdentifier = String.random()
        let expectedDate = Date()
        let expectedTaskRequest = {
            $0.earliestBeginDate = expectedDate
            return $0
        }(BGAppRefreshTaskRequest(identifier: expectedIdentifier))

        let mockScheduler = MockBackgroundTaskScheduler(pendingTaskRequests: [
            BGAppRefreshTaskRequest(identifier: "randomTaskRequest1"),
            expectedTaskRequest,
            BGAppRefreshTaskRequest(identifier: "randomTaskRequest2")
        ])
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        let unknownIdentifierResult = await sut.ongoingBackgroundTask(with: .random())
        #expect(unknownIdentifierResult == nil)

        let result = await sut.ongoingBackgroundTask(with: expectedIdentifier)
        #expect(result == expectedDate)
    }

    @Test func cancelBackgroundTask_shouldCancelTasks_withCorrespondingIdentifier() {
        let expectedIdentifier = String.random()
        let mockScheduler = MockBackgroundTaskScheduler()
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        sut.cancelBackgroundTask(withIdentifier: expectedIdentifier)

        mockScheduler.swt.assertActions(shouldBe: [.cancel(identifier: expectedIdentifier)])
    }

    // MARK: - Foreground Tasks Syncing

    @Test func registeredAndScheduledTasks_whenEarliestBeginDate_thenCancelled_shouldBeExecutedOnForeground() async throws {
        let expectedIdentifier = String.random()
        let expectedDate = Date()
        let mockScheduler = MockBackgroundTaskScheduler()
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        var backgroundTaskCallCount = 0

        sut.registerBackgroundTask(
            identifier: expectedIdentifier,
            queue: .main,
            operation: BackgroundTaskOperation(task: { completionHandler in
                backgroundTaskCallCount += 1
                completionHandler()
            })
        )
        #expect(backgroundTaskCallCount == 0)

        try sut.scheduleBackgroundTask(
            identifier: expectedIdentifier,
            earliestBeginDate: expectedDate
        )
        #expect(backgroundTaskCallCount == 0)

        timerSubject.send(expectedDate.addingTimeInterval(-1))
        #expect(backgroundTaskCallCount == 0)

        timerSubject.send(expectedDate)
        await sut.foregroundOperationTask?.value
        #expect(backgroundTaskCallCount == 1)

        timerSubject.send(expectedDate.addingTimeInterval(1))
        await sut.foregroundOperationTask?.value
        #expect(backgroundTaskCallCount == 1)
    }

    @Test func prepareForegroundTasksForExistingBackgroundTasks() async throws {
        let expectedIdentifier = String.random()
        let expectedDate = Date()
        let mockScheduler = MockBackgroundTaskScheduler(
            pendingTaskRequests: [
                newTaskRequest(
                    identifier: expectedIdentifier,
                    earliestBeginDate: expectedDate
                )
            ]
        )
        let sut = makeSUT(bgTaskScheduler: mockScheduler)

        var backgroundTaskCallCount = 0

        sut.registerBackgroundTask(
            identifier: expectedIdentifier,
            queue: .main,
            operation: BackgroundTaskOperation(task: { completionHandler in
                backgroundTaskCallCount += 1
                completionHandler()
            })
        )
        sut.prepareForegroundTasksForExistingBackgroundTasks()
        #expect(backgroundTaskCallCount == 0)

        timerSubject.send(expectedDate)
        await sut.foregroundOperationTask?.value
        #expect(backgroundTaskCallCount == 1)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        bgTaskScheduler: BackgroundTaskScheduling = MockBackgroundTaskScheduler()
    ) -> BackgroundTaskUseCase {
        BackgroundTaskUseCase(
            bgTaskScheduler: bgTaskScheduler,
            timer: timerSubject.eraseToAnyPublisher()
        )
    }

    private func newTaskRequest(
        identifier: String,
        earliestBeginDate: Date?
    ) -> BGAppRefreshTaskRequest {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate
        return request
    }
}
