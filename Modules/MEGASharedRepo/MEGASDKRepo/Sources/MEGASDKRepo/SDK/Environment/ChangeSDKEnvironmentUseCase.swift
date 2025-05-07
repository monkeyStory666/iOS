import Foundation

public protocol ChangeSDKEnvironmentUseCaseProtocol {
    func setSDKEnvironment(_ environment: SDKEnvironment)
}

public struct ChangeSDKEnvironmentUseCase: ChangeSDKEnvironmentUseCaseProtocol {
    private let repository: any ChangeSDKEnvironmentRepositoryProtocol

    public init(
        repository: some ChangeSDKEnvironmentRepositoryProtocol
    ) {
        self.repository = repository
    }

    public func setSDKEnvironment(_ environment: SDKEnvironment) {
        repository.setSDKEnvironment(environment)
    }
}
