// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import StoreKit

extension SKProductSubscriptionPeriod {
    func dateComponents() -> DateComponents {
        var dateComponents = DateComponents()

        switch unit {
        case .day:
            dateComponents.day = numberOfUnits
        case .week:
            dateComponents.weekOfYear = numberOfUnits
        case .month:
            dateComponents.month = numberOfUnits
        case .year:
            dateComponents.year = numberOfUnits
        @unknown default:
            break
        }

        return dateComponents
    }
}
