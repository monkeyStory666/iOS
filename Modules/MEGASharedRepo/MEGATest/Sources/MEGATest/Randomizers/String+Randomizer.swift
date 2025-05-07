// Copyright © 2023 MEGA Limited. All rights reserved.

public extension String {
    static func random(withPrefix prefix: String = "", length: Int = 16) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomLength = Swift.max(length - prefix.count, 0)
        let randomString = String((0..<randomLength).map { _ in letters.randomElement()! })
        return prefix + randomString
    }
}
