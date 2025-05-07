import MEGAWhatsNew

public final class MockAppVersionPersistanceUseCase: AppVersionPersistanceUseCaseProtocol {
    public var persistedVersions: [String]

    public init(
        persistedVersions: [String] = []
    ) {
        self.persistedVersions = persistedVersions
    }
    public func shouldDisplayWhatsNew(for version: String) -> Bool {
        return !persistedVersions.contains(version)
    }
    public func storeWhatsNewDisplayed(for version: String) {
        persistedVersions.append(version)
    }
}
