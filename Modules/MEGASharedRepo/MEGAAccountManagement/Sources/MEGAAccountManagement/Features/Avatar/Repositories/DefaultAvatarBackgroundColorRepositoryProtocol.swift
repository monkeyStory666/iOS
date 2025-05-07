// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol DefaultAvatarBackgroundColorRepositoryProtocol {
    func fetchBackgroundColor() async throws -> String
    func fetchSecondaryBackgroundColor() async throws -> String
}
