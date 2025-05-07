import MEGASdk
import MEGASDKRepo
import MEGASwift

public protocol UsersUpdateRepositoryProtocol {
    func currentUserUpdate(filterBy changeTypeSet: UserEntity.ChangeTypeEntity) -> AnyAsyncSequence<UserEntity>
}

public struct UsersUpdateRepository: UsersUpdateRepositoryProtocol {
    private let sdk: MEGASdk
    private let usersUpdateStream: any UsersUpdateStreamProtocol

    public init(
        sdk: MEGASdk,
        usersUpdateStream: some UsersUpdateStreamProtocol
    ) {
        self.sdk = sdk
        self.usersUpdateStream = usersUpdateStream
    }

    public func currentUserUpdate(filterBy changeTypeSet:UserEntity.ChangeTypeEntity) -> AnyAsyncSequence<UserEntity> {
        return usersUpdateStream
            .updates
            .compactMap { userList in
                let users = userList.toUserEntities()
                guard let currentUser = sdk.myUser?.toUserEntity(),
                      let changedCurrentUser = users.first(where: { $0.handle == currentUser.handle }) else {
                    return nil
                }
                return changedCurrentUser
            }
            .filter { changedUser in
                changedUser.changes.intersection(changeTypeSet).isNotEmpty
            }
            .eraseToAnyAsyncSequence()
    }
}
