
public protocol DeleteAccountRepositoryProtocol {
    func myEmail() -> String?
    func deleteAccount(with pin: String?) async throws
    func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform
    func hasLoggedOut() async -> Bool
}
