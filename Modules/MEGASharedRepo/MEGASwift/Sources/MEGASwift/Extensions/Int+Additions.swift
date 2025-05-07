import Foundation

// MARK: - Int Extensions for String Conversion and Formatting

public extension Int {
    /// Returns a string representation of the integer if it is a single digit; otherwise, returns "0".
    ///
    /// This property is useful when you want to ensure that only single-digit values are represented as their
    /// actual value. For values 10 or greater, it defaults to "0".
    var digitString: String {
        guard self < 10 else { return "0" }
        return String(self)
    }
}

public extension Int {
    /// Returns a formatted string representation of the integer as a time interval.
    ///
    /// The integer is interpreted as a time interval in seconds. This method uses a `DateComponentsFormatter`
    /// with the specified allowed units and style to produce a string representation.
    ///
    /// - Parameters:
    ///   - allowedUnits: The calendar units allowed in the formatted string (e.g., hour, minute, second).
    ///   - unitStyle: The style of the units. Defaults to `.full`.
    /// - Returns: A formatted string representing the time interval, or `nil` if formatting fails.
    func string(
        allowedUnits: NSCalendar.Unit,
        unitStyle: DateComponentsFormatter.UnitsStyle = .full
    ) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.unitsStyle = unitStyle
        return formatter.string(from: TimeInterval(self))
    }
    
    /// Generates a random integer within the full range of `Int`.
    ///
    /// - Returns: A random integer between `Int.min` and `Int.max`.
    static func random() -> Int {
        Int.random(in: Int.min...Int.max)
    }
    
    /// Returns a localized string representation of the integer without any formatting.
    ///
    /// This property uses a `NumberFormatter` with the `.none` number style to convert the integer into a string.
    ///
    /// - Returns: A string representation of the integer, or `nil` if formatting fails.
    var cardinal: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter.string(from: NSNumber(value: self))
    }
}

// MARK: - Int Extensions for TimeInterval Conversions

public extension Int {
    /// Interprets the integer as seconds and returns the corresponding `TimeInterval`.
    var seconds: TimeInterval { TimeInterval(self) }
    
    /// Converts the integer (assumed to be seconds) to minutes.
    var minutes: TimeInterval { seconds * 60 }
    
    /// Converts the integer (assumed to be seconds) to hours.
    var hours: TimeInterval { minutes * 60 }
    
    /// Converts the integer (assumed to be seconds) to days.
    var days: TimeInterval { hours * 24 }
}

// MARK: - Int Extensions for Byte Count Formatting

public extension Int {
    /// Converts the integer, interpreted as the number of gigabytes, into a formatted string.
    ///
    /// The method multiplies the integer by the number of bytes in one gigabyte (1024³) and then uses a
    /// `ByteCountFormatter` with binary count style to produce a human-readable string.
    ///
    /// - Returns: A formatted string representing the byte count in gigabytes.
    func toGBString() -> String {
        let bytes: Int64 = Int64(self * 1024 * 1024 * 1024)
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .binary)
    }
}

// MARK: - Int64 Extensions for Byte Conversion

public extension Int64 {
    /// Converts a byte count into the equivalent number of gigabytes.
    ///
    /// The method divides the byte count by 1024³ (the number of bytes in one gigabyte) and returns the result as an integer,
    /// truncating any fractional part.
    ///
    /// - Returns: The number of gigabytes represented by the byte count.
    func bytesToGigabytes() -> Int {
        let bytesInGB: Double = 1024 * 1024 * 1024  // 1 GB in bytes
        let gigabytes = Double(self) / bytesInGB
        return Int(gigabytes)
    }
}
