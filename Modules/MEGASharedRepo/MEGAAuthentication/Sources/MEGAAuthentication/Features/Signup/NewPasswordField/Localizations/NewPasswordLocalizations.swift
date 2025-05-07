
import Foundation

public struct NewPasswordLocalizations {
    /// NSLocalizedString key: "account.newPassword.passwordLabel"
    public let passwordLabel: String
    
    /// NSLocalizedString key: "account.newPassword.confirmPasswordLabel"
    public let confirmPasswordLabel: String
    
    /// NSLocalizedString key: "account.newPassword.betterToHave"
    public let betterToHave: String
    
    /// NSLocalizedString key: "account.newPassword.minimumCharacter"
    public let minimumCharacter: String

    /// NSLocalizedString key: "account.newPassword.veryWeakPassword"
    public let veryWeakPassword: String

    /// NSLocalizedString key: "account.newPassword.weakPassword"
    public let weakPassword: String

    /// NSLocalizedString key: "account.newPassword.upperAndLowerCase"
    public let upperAndLowerCase: String

    /// NSLocalizedString key: "account.newPassword.oneNumberOrSpecial"
    public let oneNumberOrSpecial: String

    /// NSLocalizedString key: "account.newPassword.confirmPasswordError"
    public let confirmPasswordError: String

    /// NSLocalizedString key: "account.newPassword.passwordDoNotMatch"
    public let passwordDoNotMatch: String
    
    public init(
        passwordLabel: String,
        confirmPasswordLabel: String,
        betterToHave: String,
        minimumCharacter: String,
        veryWeakPassword: String,
        weakPassword: String,
        upperAndLowerCase: String,
        oneNumberOrSpecial: String,
        confirmPasswordError: String,
        passwordDoNotMatch: String
    ) {
        self.passwordLabel = passwordLabel
        self.confirmPasswordLabel = confirmPasswordLabel
        self.betterToHave = betterToHave
        self.minimumCharacter = minimumCharacter
        self.veryWeakPassword = veryWeakPassword
        self.weakPassword = weakPassword
        self.upperAndLowerCase = upperAndLowerCase
        self.oneNumberOrSpecial = oneNumberOrSpecial
        self.confirmPasswordError = confirmPasswordError
        self.passwordDoNotMatch = passwordDoNotMatch
    }
}

public extension NewPasswordLocalizations {
    static var preview: NewPasswordLocalizations {
        return NewPasswordLocalizations(
            passwordLabel: "Password",
            confirmPasswordLabel: "Confirm password",
            betterToHave: "It's better to have:",
            minimumCharacter: "Must have at least 8 characters",
            veryWeakPassword: "Your password is too easy to guess. You need to try a stronger combination of characters.",
            weakPassword: "Your password is easy to guess. We suggest trying a stronger combination of characters.",
            upperAndLowerCase: "Upper and lower case letters",
            oneNumberOrSpecial: "At least one number or special character",
            confirmPasswordError: "Confirm password",
            passwordDoNotMatch: "Passwords don’t match. Check and try again"
        )
    }
}
