// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct RemoteFeatureFlagRepository: RemoteFeatureFlagRepositoryProtocol {
    let megaSdk: MEGASdk

    var withAsyncThrowingValueWithTimeout: (
        TimeInterval?,
        @Sendable @escaping (@escaping (Result<Int, Error>) -> Void) -> Void
    ) async throws -> Int

    var runInUserInitiatedTask: (
        @Sendable @escaping @isolated(any) () async -> Void
    ) -> ()

    public func get(for key: String) async throws -> Int {
        try await withAsyncThrowingValueWithTimeout(3) { completion in
            runInUserInitiatedTask {
                let result = self.megaSdk.remoteFeatureFlagValue(key)
                completion(Result.success(result))
            }
        }
    }
}
