import Foundation

enum Constants {
    static var recoveryKeyFileName: String { "MEGA-RECOVERYKEY.txt" }

    enum Link {
        static let playStore = URL(string: "https://play.google.com/")!
        static let megaWebsite = URL(string: "https://mega.nz/")!
        static let appStoreSubscriptions = URL(string: "https://apps.apple.com/account/subscriptions")!
        static var recoveryKeyLearnMore = URL(
            string: "https://help.mega.io/accounts/password-management/recovery-key"
        )!
    }
}
