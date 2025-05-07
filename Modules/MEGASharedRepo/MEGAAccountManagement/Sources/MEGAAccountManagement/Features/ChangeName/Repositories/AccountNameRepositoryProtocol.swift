// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol AccountNameRepositoryProtocol {
    func changeName(
        firstName: String,
        lastName: String
    ) async throws
}
