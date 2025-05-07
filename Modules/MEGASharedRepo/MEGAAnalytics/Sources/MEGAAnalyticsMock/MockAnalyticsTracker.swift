import Foundation
import MEGAAnalytics
import MEGAAnalyticsiOS
import Testing
import XCTest

public class MockAnalyticsTracking: AnalyticsTracking {
    public var trackedEvents: [any AnalyticsEventEntityProtocol] = []

    public init(trackedEvents: [any AnalyticsEventEntityProtocol] = []) {
        self.trackedEvents = trackedEvents
    }

    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        trackedEvents.append(event)
    }
}

// Note: This is a workaround to bypass the typecasting issue with the opaque type.
public extension MockAnalyticsTracking {
    func assertsEventsEmpty(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            trackedEvents.isEmpty,
            file: file,
            line: line
        )
    }

    func assertsEventsEqual(
        to eventsRawValue: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            trackedEvents.map(\.rawValue),
            eventsRawValue,
            file: file,
            line: line
        )
    }

    func assertsEventsEqual(
        to events: [any AnalyticsEventEntityProtocol],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertsEventsEqual(
            to: events.map(\.rawValue),
            file: file,
            line: line
        )
    }

    func assertsEventsEqual(
        to events: [AnalyticsEventEntity],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertsEventsEqual(
            to: events.map(\.rawValue),
            file: file,
            line: line
        )
    }
}

public extension MockAnalyticsTracking {
    struct SWT {
        private let mockTracker: MockAnalyticsTracking

        init(mockTracker: MockAnalyticsTracking) {
            self.mockTracker = mockTracker
        }

        public func assertsEventsEmpty() {
            #expect(mockTracker.trackedEvents.isEmpty)
        }

        public func assertsEventsEqual(to eventsRawValue: [String]) {
            #expect(
                mockTracker.trackedEvents.map(\.rawValue) ==
                eventsRawValue
            )
        }

        public func assertsEventsEqual(to events: [any AnalyticsEventEntityProtocol]) {
            assertsEventsEqual(to: events.map(\.rawValue))
        }

        public func assertsEventsEqual(to events: [AnalyticsEventEntity]) {
            assertsEventsEqual(to: events.map(\.rawValue))
        }
    }

    /// Provides access to the Swift Testing (SWT) namespace.
    var swt: SWT {
        return SWT(mockTracker: self)
    }
}

public struct MockMegaAnalyticsTracker: MEGAAnalyticsTrackerProtocol {
    public var tracker: AnalyticsTracking

    public init(
        tracker: AnalyticsTracking
    ) {
        self.tracker = tracker
    }

    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        tracker.trackAnalyticsEvent(with: event)
    }
}
