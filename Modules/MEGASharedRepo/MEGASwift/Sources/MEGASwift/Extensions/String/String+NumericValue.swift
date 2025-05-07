// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

/// An extension on String to provide a computed property that returns a new string containing only
/// the numeric characters.
public extension String {
    /// Returns a new string containing only the numeric characters from the original string.
    ///
    /// For example, if the original string is "abc123def456", the resulting string will be
    /// "123456".
    var numericValue: String {
        // Filters the characters of the string and keeps only those that are whole numbers.
        filter(\.isWholeNumber)
    }
}
