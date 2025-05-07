import MEGASdk

public protocol ViewIDRepositoryProtocol {
    func generateViewId() -> ViewID?
}

public final class ViewIDRepository: ViewIDRepositoryProtocol {

    public static var newRepo: ViewIDRepository {
        ViewIDRepository(sdk: DependencyInjection.sharedSdk)
    }

    private let sdk: MEGASdk

    init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func generateViewId() -> ViewID? {
        sdk.generateViewId()
    }
}
