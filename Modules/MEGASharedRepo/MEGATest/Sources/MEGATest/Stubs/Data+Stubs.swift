// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public extension Data {
    static var invalidData: Data { "invalid data \(Int.random())".data(using: .utf8)! }
}
