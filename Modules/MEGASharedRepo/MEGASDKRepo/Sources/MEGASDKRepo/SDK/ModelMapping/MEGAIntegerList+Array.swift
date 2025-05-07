// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk

public extension MEGAIntegerList {
    var array: [Int] {
        var array = [Int]()
        for index in 0 ..< size {
            if let integer = Int(exactly: integer(at: index)) {
                array.append(integer)
            }
        }
        return array
    }
}
