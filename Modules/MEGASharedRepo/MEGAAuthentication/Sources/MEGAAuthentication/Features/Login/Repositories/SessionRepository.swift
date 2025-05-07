import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct SessionRepository: SessionRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public var sessionUpdates: AnyAsyncSequence<SessionEntity> {
        RequestStream(sdk: sdk)
            .requestEvents
            .compactMap { result in
                switch result {
                case .success(let request) where request.type == .MEGARequestTypeLogin:
                    return .login
                case .success(let request) where request.isLogoutByInvalidSession:
                    return .invalidSession
                case .failure(let error) where error.type == .apiESid:
                    return .invalidSession
                default:
                    return nil
                }
            }
            .eraseToAnyAsyncSequence()
    }
}

private extension MEGARequest {
    var isLogoutByInvalidSession: Bool {
        type == .MEGARequestTypeLogout && hasBadSessionId
    }

    private var hasBadSessionId: Bool {
        paramType == -15
    }
}
