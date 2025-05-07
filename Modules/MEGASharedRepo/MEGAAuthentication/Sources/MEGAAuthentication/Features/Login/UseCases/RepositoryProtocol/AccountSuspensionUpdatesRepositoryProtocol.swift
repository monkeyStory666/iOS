import MEGASwift

public protocol AccountSuspensionUpdatesRepositoryProtocol: Sendable {
    var accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity> { get }
}
