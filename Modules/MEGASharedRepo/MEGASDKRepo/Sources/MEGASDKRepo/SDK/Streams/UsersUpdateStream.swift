import MEGASdk
import MEGASwift

public protocol UsersUpdateStreamProtocol: Sendable {
    /// User updates from `MEGAGlobalDelegate` `onUsersUpdate` as an `AnyAsyncSequence`
    ///
    /// - Returns: `AnyAsyncSequence` that will call sdk.add on creation and sdk.remove onTermination of `AsyncStream`.
    /// It will yield `MEGAUserList` on user changes  until sequence terminated
    var updates: AnyAsyncSequence<MEGAUserList> { get }
}

public struct UsersUpdateStream: UsersUpdateStreamProtocol {
    public var updates: AnyAsyncSequence<MEGAUserList> {
        AsyncStream { continuation in
            let usersUpdateDelegate = UsersUpdateDelegate { megaUserList in
                continuation.yield(megaUserList)
            }
            sdk.add(usersUpdateDelegate, queueType: .globalBackground)
            continuation.onTermination = { _ in
                sdk.remove(usersUpdateDelegate)
            }
        }
        .eraseToAnyAsyncSequence()
    }

    private let sdk: MEGASdk
    
    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }
}


final class UsersUpdateDelegate: NSObject, MEGAGlobalDelegate, Sendable {
    
    private let onUsersUpdate: @Sendable (MEGAUserList) -> Void
    
    init(onUsersUpdate: @escaping @Sendable (MEGAUserList) -> Void) {
        self.onUsersUpdate = onUsersUpdate
    }
    
    func onUsersUpdate(_ api: MEGASdk, userList: MEGAUserList) {
        onUsersUpdate(userList)
    }
}
