import MEGAAccountManagement
import MEGATest
import UIKit

public final class MockFetchUIImageAvatarUseCase:
    MockObject<MockFetchUIImageAvatarUseCase.Action>,
    FetchUIImageAvatarUseCaseProtocol {
    public enum Action: Equatable {
        case fetchAvatarForCurrentUser(Bool)
    }

    public override init() {}

    var _fetchAvatarForCurrentUser: UIImage?

    public init(fetchAvatarForCurrentUser: UIImage? = nil) {
        self._fetchAvatarForCurrentUser = fetchAvatarForCurrentUser
    }

    public func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> UIImage? {
        actions.append(.fetchAvatarForCurrentUser(reloadIgnoringLocalCache))
        return _fetchAvatarForCurrentUser
    }
}

