import MEGASwift

public protocol AccountSuspensionUpdatesUseCaseProtocol: Sendable {
    /// Account suspension updates from `MEGAGlobalDelegate` `onEvent` for `.accountBlocked` event
    /// type as an `AnyAsyncSequence`
    ///
    /// - Returns: `AnyAsyncSequence` that will call `EventStream` and filter `.accountBlocked` events
    /// onTermination of `AsyncStream`.
    /// It will yield `AccountSuspensionTypeEntity` item until sequence terminated
    var accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity> { get }
}

public struct AccountSuspensionUpdatesUseCase: AccountSuspensionUpdatesUseCaseProtocol {
    private let repo: any AccountSuspensionUpdatesRepositoryProtocol

    public init(repo: some AccountSuspensionUpdatesRepositoryProtocol) {
        self.repo = repo
    }

    public var accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity> {
        repo.accountSuspensionUpdates
    }
}
