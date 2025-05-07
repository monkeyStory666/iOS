// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift

public extension RemoteDataRepositoryProtocol {
    func fetch(timeout: TimeInterval) async throws -> RemoteData {
        try await withTimeout(nanoseconds: UInt64(timeout) * NSEC_PER_SEC) {
            try await fetch()
        }
    }
}
