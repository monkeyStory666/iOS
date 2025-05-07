// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGANotifications
@testable import MEGANotificationsMocks
import Foundation
import MEGATest
import Testing
import UserNotifications

struct LocalNotificationUseCaseTests {
    @Test func requestNotification_shouldMapDefaultArgumentsCorrectly() async throws {
        try await assertWhen(content: content()) { content, _ in
            #expect(content.title == expectedTitle)
            #expect(content.body == expectedBody)
            #expect(expectedUserInfo == content.userInfo as? [String: String])
            #expect(expectedBadge == content.badge as? Int)
            #expect(content.relevanceScore == expectedRelevanceScore)
        }
    }

    @Test func requestNotification_shouldMapTriggersCorrectly() async throws {
        let expectedTimeInterval = TimeInterval.random(in: 61...1000)
        try await assertWhen(
            content: content(),
            trigger: .timeInterval(expectedTimeInterval, repeats: expectedTriggerRepeats),
            assertion: { content, trigger in
                let timeIntervalTrigger = try #require(trigger as? UNTimeIntervalNotificationTrigger)
                #expect(timeIntervalTrigger.timeInterval == expectedTimeInterval)
                #expect(timeIntervalTrigger.repeats == expectedTriggerRepeats)
            }
        )

        let expectedDateComponents = DateComponents(calendar: .current, hour: 12, minute: 0)
        try await assertWhen(
            content: content(),
            trigger: .calendar(dateMatching: expectedDateComponents, repeats: expectedTriggerRepeats),
            assertion: { content, trigger in
                let calendarTrigger = try #require(trigger as? UNCalendarNotificationTrigger)
                #expect(calendarTrigger.dateComponents == expectedDateComponents)
                #expect(calendarTrigger.repeats == expectedTriggerRepeats)
            }
        )
    }

    @Test func requestNotification_shouldMapSoundCorrectly() async throws {
        try await assertWhen(content: content(sound: .default)) { content, _ in
            #expect(content.sound == .default)
        }

        try await assertWhen(content: content(sound: .defaultCritical)) { content, _ in
            #expect(content.sound == .defaultCritical)
        }

        if #available(iOS 15.2, *) {
            try await assertWhen(content: content(sound: .defaultRingtone)) { content, _ in
                #expect(content.sound == .defaultRingtone)
            }
        }
    }

    @Test func requestNotifications_shouldMapInterruptLevelCorrectly() async throws {
        try await assertWhen(content: content(interruptionLevel: .passive)) { content, _ in
            #expect(content.interruptionLevel == .passive)
        }

        try await assertWhen(content: content(interruptionLevel: .timeSensitive)) { content, _ in
            #expect(content.interruptionLevel == .timeSensitive)
        }

        try await assertWhen(content: content(interruptionLevel: .critical)) { content, _ in
            #expect(content.interruptionLevel == .critical)
        }

        try await assertWhen(content: content(interruptionLevel: .active)) { content, _ in
            #expect(content.interruptionLevel == .active)
        }
    }

    @Test func removeDeliveredNotifications() {
        let expectedIdentifiers = [String.random()]
        let mockScheduler = MockLocalNotificationScheduler()
        let sut = makeSUT(localNotificationScheduler: mockScheduler)

        sut.removeDeliveredNotifications(withIdentifiers: expectedIdentifiers)

        mockScheduler.swt.assertActions(
            shouldBe: [.removeDeliveredNotifications(
                identifiers: expectedIdentifiers
            )]
        )
    }

    @Test func cancelPendingNotifications() {
        let expectedIdentifiers = [String.random()]
        let mockScheduler = MockLocalNotificationScheduler()
        let sut = makeSUT(localNotificationScheduler: mockScheduler)

        sut.cancelPendingNotificationRequests(withIdentifiers: expectedIdentifiers)

        mockScheduler.swt.assertActions(
            shouldBe: [.removePendingNotificationRequests(
                identifiers: expectedIdentifiers
            )]
        )
    }

    @Test func removeAllDeliveredNotifications() {
        let mockScheduler = MockLocalNotificationScheduler()
        let sut = makeSUT(localNotificationScheduler: mockScheduler)

        sut.removeAllDeliveredNotifications()

        mockScheduler.swt.assertActions(shouldBe: [.removeAllDeliveredNotifications])
    }

    @Test func cancelAllPendingNotifications() {
        let mockScheduler = MockLocalNotificationScheduler()
        let sut = makeSUT(localNotificationScheduler: mockScheduler)

        sut.cancelAllPendingNotificationRequests()

        mockScheduler.swt.assertActions(shouldBe: [.removeAllPendingNotificationRequests])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        localNotificationScheduler: LocalNotificationScheduling = MockLocalNotificationScheduler()
    ) -> LocalNotificationUseCase {
        LocalNotificationUseCase(
            localNotificationScheduler: localNotificationScheduler
        )
    }

    // Can't use Swift Testing test arguments because UN types is not sendable
    // thus causing crashes when running unit tests
    private func assertWhen(
        content: NotificationContent,
        trigger: NotificationTrigger = .timeInterval(123, repeats: .random()),
        assertion: (UNNotificationContent, UNNotificationTrigger) throws -> Void
    ) async throws {
        let expectedIdentifier = String.random()
        let mockScheduler = MockLocalNotificationScheduler()
        let sut = makeSUT(localNotificationScheduler: mockScheduler)

        try await sut.requestNotification(
            identifier: expectedIdentifier,
            content: content,
            trigger: trigger
        )

        #expect(mockScheduler.actions.count == 1)

        if case let .requestNotification(identifier, content, trigger) = mockScheduler.actions.first {
            #expect(identifier == expectedIdentifier)
            try assertion(content, trigger)
        } else {
            Issue.record("Expected to call requestNotification action")
        }
    }

    private let expectedTitle = String.random()
    private let expectedBody = String.random()
    private let expectedUserInfo = [String.random(): String.random()]
    private let expectedBadge = Int.random(in: 0...100)
    private let expectedRelevanceScore = Double.random(in: 0...1)
    private let expectedTriggerRepeats = Bool.random()

    private func content(
        sound: NotificationSound? = nil,
        interruptionLevel: NotificationInterruptionLevel = .passive
    ) -> NotificationContent {
        NotificationContent(
            title: expectedTitle,
            body: expectedBody,
            sound: sound,
            userInfo: expectedUserInfo,
            badge: expectedBadge,
            interruptionLevel: interruptionLevel,
            relevanceScore: expectedRelevanceScore
        )
    }
}
