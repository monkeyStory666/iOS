// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure

public protocol FetchAvatarUseCaseProtocol {
    associatedtype Image

    func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> Image?
}

public struct FetchAvatarUseCase<Image>: FetchAvatarUseCaseProtocol {
    public typealias ImageFromData = (Data) -> Image?
    private let repository: any UserAvatarRepositoryProtocol
    private let fileSystemRepository: any FileSystemRepositoryProtocol
    private let fetchAccountUseCase: any FetchAccountUseCaseProtocol
    private let imageFromData: ImageFromData

    public init(
        repository: some UserAvatarRepositoryProtocol,
        fileSystemRepository: some FileSystemRepositoryProtocol,
        fetchAccountUseCase: some FetchAccountUseCaseProtocol,
        imageFromData: @escaping ImageFromData
    ) {
        self.repository = repository
        self.fileSystemRepository = fileSystemRepository
        self.fetchAccountUseCase = fetchAccountUseCase
        self.imageFromData = imageFromData
    }

    public func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> Image? {
        guard let account = try? await fetchAccountUseCase.fetchAccount() else { return nil }

        let base64Handle = account.base64Handle
        let destinationFilePath = fileSystemRepository.cacheDirectory().appendingPathComponent(base64Handle).path

        if reloadIgnoringLocalCache,
           case let url = URL(fileURLWithPath: destinationFilePath),
           fileSystemRepository.fileExists(at: url) {
            fileSystemRepository.removeFile(at: url)
        }

        if let data = try? await repository.fetchAvatar(for: base64Handle, destinationFilePath: destinationFilePath) {
            return imageFromData(data)
        } else {
            return nil
        }
    }
}

