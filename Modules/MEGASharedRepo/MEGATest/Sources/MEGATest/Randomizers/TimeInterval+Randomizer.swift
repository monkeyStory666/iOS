// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift

public extension TimeInterval {
    static func random() -> Self {
        TimeInterval(Int.random())
    }
}
