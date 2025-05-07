// Copyright © 2023 MEGA Limited. All rights reserved.

public struct ConfirmPasswordIssues: OptionSet {
    public var rawValue: Int

    public static let emptyPassword = ConfirmPasswordIssues(rawValue: 1 << 0)
    public static let doesNotMatch = ConfirmPasswordIssues(rawValue: 1 << 1)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(newPassword: String, confirmPassword: String) {
        var options: ConfirmPasswordIssues = []

        if confirmPassword.isEmpty {
            options.insert(.emptyPassword)
        } else if newPassword != confirmPassword {
            options.insert(.doesNotMatch)
        }

        self = options
    }

    public func highestPriorityError() -> ConfirmPasswordIssues? {
        if self.contains(.emptyPassword) {
            return .emptyPassword
        } else if self.contains(.doesNotMatch) {
            return .doesNotMatch
        }
        return nil
    }
}
