// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk

public extension MEGAStringList {
    var array: [String] {
        var array = [String]()
        for index in 0 ..< size {
            if let string = string(at: index) {
                array.append(string)
            }
        }
        return array
    }
}
