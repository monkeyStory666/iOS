import MEGAAnalyticsiOS
import XCTest

public extension XCTestCase {
    func assertTrackAnalyticsEventCalled(
        trackedEventIdentifiers: [any EventIdentifier],
        with expectedEventIdentifiers: [any EventIdentifier],
        message: String = "",
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(
            trackedEventIdentifiers.count,
            expectedEventIdentifiers.count,
            file: file, line: line
        )
        
        for (tracked, expected) in zip(expectedEventIdentifiers, trackedEventIdentifiers) {
            XCTAssertEqual(
                tracked.stringValue,
                expected.stringValue,
                message,
                file: file, line: line
            )
        }
    }
    
    func XCTAssertTrackedAnalyticsEventsEqual(
        _ events: [any EventIdentifier],
        _ expected: [any EventIdentifier],
        message: String = "",
        file: StaticString = #file, line: UInt = #line
    ) {
        assertTrackAnalyticsEventCalled(trackedEventIdentifiers: events, with: expected, message: message)
    }
}

private extension EventIdentifier {
    var stringValue: String {
        String(describing: type(of: self))
    }
}
