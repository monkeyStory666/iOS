// Copyright © 2023 MEGA Limited. All rights reserved.

import UIKit

public protocol FetchUIImageAvatarUseCaseProtocol {
    func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> UIImage?
}

public struct FetchUIImageAvatarUseCase<
    T: FetchAvatarUseCaseProtocol
>: FetchUIImageAvatarUseCaseProtocol where T.Image == UIImage {
    private let fetchAvatarUseCase: T

    public init(fetchAvatarUseCase: T) {
        self.fetchAvatarUseCase = fetchAvatarUseCase
    }

    public func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> UIImage? {
        await fetchAvatarUseCase.fetchAvatarForCurrentUser(reloadIgnoringLocalCache: reloadIgnoringLocalCache)
    }
}
