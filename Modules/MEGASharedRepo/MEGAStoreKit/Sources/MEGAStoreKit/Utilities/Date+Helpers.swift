// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

extension Range where Bound == Date {
    init(
        adding dateComponents: DateComponents,
        from startingDate: Date = Date(),
        calendar: Calendar = .current
    ) {
        guard let endDate = calendar.date(byAdding: dateComponents, to: startingDate) else {
            self = startingDate..<startingDate
            return
        }

        self = startingDate..<endDate
    }
}
