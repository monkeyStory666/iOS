import MEGATest
import MEGASDKRepo

public final class MockChangeSDKEnvironmentUseCase:
    MockObject<MockChangeSDKEnvironmentUseCase.Action>,
    ChangeSDKEnvironmentUseCaseProtocol
{
    public enum Action: Equatable {
        case setSDKEnvironment(SDKEnvironment)
    }

    public var refreshSession: (() async -> Void)?

    public func setSDKEnvironment(_ environment: SDKEnvironment) {
        actions.append(.setSDKEnvironment(environment))
    }
}
