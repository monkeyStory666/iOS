// Copyright © 2023 MEGA Limited. All rights reserved.

public typealias CallFrequency = Int

public extension CallFrequency {
    static var once: Self { 1 }
    static var twice: Self { 2 }
}

public extension Int {
    var times: CallFrequency { self }
}
