// Copyright © 2023 MEGA Limited. All rights reserved.

public struct PasswordRecommendations: OptionSet {
    public var rawValue: Int

    public static let upperAndLowercaseLetters = PasswordRecommendations(rawValue: 1 << 0)
    public static let oneNumberOrSpecialCharacter = PasswordRecommendations(rawValue: 1 << 1)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(for password: String) {
        var options: PasswordRecommendations = []

        if password.range(of: "[A-Z]", options: .regularExpression) != nil &&
            password.range(of: "[a-z]", options: .regularExpression) != nil {
            options.insert(.upperAndLowercaseLetters)
        }

        if password.range(of: "[0-9!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil {
            options.insert(.oneNumberOrSpecialCharacter)
        }

        self = options
    }
}
