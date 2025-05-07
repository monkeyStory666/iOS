import MEGASwift

public protocol SessionUseCaseProtocol {
    /// Session updates from `MEGARequestDelegate`'s `onRequestFinish`.
    ///
    /// - Returns: `AnyAsyncSequence` that will call `RequestStream` and filter `SessionEntity` events
    /// onTermination of `AsyncStream`.
    /// 
    /// It will yield ` SessionEntity` item until sequence terminated
    var sessionUpdates: AnyAsyncSequence<SessionEntity> { get }
}

public struct SessionUseCase: SessionUseCaseProtocol {
    private let repo: any SessionRepositoryProtocol

    public init(repo: some SessionRepositoryProtocol) {
        self.repo = repo
    }

    public var sessionUpdates: AnyAsyncSequence<SessionEntity> {
        repo.sessionUpdates
    }
}
