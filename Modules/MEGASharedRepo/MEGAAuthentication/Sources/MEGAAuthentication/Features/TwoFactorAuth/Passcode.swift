// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct Passcode: Equatable {
    private var values: [Int]
    public let maxCount: Int
    private let range: Range<Int>

    public var string: String {
        values.reduce(into: "") { $0 += String($1) }
    }

    public var count: Int { values.count }
    public var isEmpty: Bool { values.isEmpty }
    public var containsMaxValues: Bool { count >= maxCount }

    public init(
        values: [Int] = [],
        maxCount: Int = 6,
        range: Range<Int> = 0 ..< 10
    ) {
        self.values = Array(values.prefix(maxCount))
        self.maxCount = maxCount
        self.range = range
    }

    public init(
        text: String,
        maxCount: Int = 6,
        range: Range<Int> = 0 ..< 10
    ) {
        self.init(
            values: Array(text.digits.filter { range.contains($0) }.prefix(maxCount)),
            maxCount: maxCount,
            range: range
        )
    }

    public subscript(index: Int) -> Int {
        get { values[index] }
        set { values[index] = newValue }
    }
}
