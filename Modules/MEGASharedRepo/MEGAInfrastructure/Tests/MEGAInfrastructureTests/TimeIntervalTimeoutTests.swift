// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import Testing

struct TimeIntervalTimeoutTests {
    struct TimeoutArguments {
        let timeInterval: TimeInterval
        let expectedTimeOut: TimeInterval
    }

    @Test(
        arguments: [
            TimeoutArguments(
                timeInterval: .veryShort,
                expectedTimeOut: 3
            ),
            TimeoutArguments(
                timeInterval: .short,
                expectedTimeOut: 10
            ),
            TimeoutArguments(
                timeInterval: .medium,
                expectedTimeOut: 30
            ),
            TimeoutArguments(
                timeInterval: .long,
                expectedTimeOut: 60
            ),
            TimeoutArguments(
                timeInterval: .veryLong,
                expectedTimeOut: 120
            )
        ]
    ) func testTimeout(
        arguments: TimeoutArguments
    ) {
        #expect(arguments.timeInterval == arguments.expectedTimeOut)
    }
}
