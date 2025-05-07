// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol LoginStoreRepositoryProtocol: Sendable {
    func set(session: String, updateDuplicateSession: Bool) throws
    func session() throws -> String
    func delete() throws
}
