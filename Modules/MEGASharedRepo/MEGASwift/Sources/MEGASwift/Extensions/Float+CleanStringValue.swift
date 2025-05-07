// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public extension Float {
    /// Converts a float value to a string without decimal points.
    ///
    /// - Returns: A string representation of the float value without decimal points.
    var cleanStringValue: String {
        formatted(.number.precision(.fractionLength(0)))
    }
}
