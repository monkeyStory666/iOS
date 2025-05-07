// Copyright © 2023 MEGA Limited. All rights reserved.

public struct NewPasswordIssues: OptionSet {
    public static var minimumCharacters: Int { 8 }

    public var rawValue: Int

    public static let lessThanMinimumCharacters = NewPasswordIssues(rawValue: 1 << 0)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(from newPassword: String) {
        var options: NewPasswordIssues = []

        if newPassword.count < NewPasswordIssues.minimumCharacters {
            options.insert(.lessThanMinimumCharacters)
        }

        self = options
    }
}
