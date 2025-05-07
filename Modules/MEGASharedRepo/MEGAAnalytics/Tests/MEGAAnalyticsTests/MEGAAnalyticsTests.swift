import XCTest
@testable import MEGAAnalytics
import MEGAAnalyticsMock

final class MEGAAnalyticsTests: XCTestCase {
    func testAnalyticsEventTrackingTriggered_whenTrackingTriggered_shouldTrackEventCorrectly() {
        let mockAnalyticsTracker = MockAnalyticsTracking()
        let sut = MockMegaAnalyticsTracker(tracker: mockAnalyticsTracker)

        sut.trackAnalyticsEvent(with: .accountActivated)

        mockAnalyticsTracker.assertsEventsEqual(to: [.accountActivated])
    }
}
