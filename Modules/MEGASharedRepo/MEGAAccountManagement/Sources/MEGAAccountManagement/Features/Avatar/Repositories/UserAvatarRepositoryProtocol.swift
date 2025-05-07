// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol UserAvatarRepositoryProtocol {
    func fetchAvatar(for handle: Base64HandleEntity, destinationFilePath: String) async throws -> Data?
}
