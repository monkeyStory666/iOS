// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAInfrastructure
import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASDKRepoMocks
import Testing

struct RemoteFeatureFlagRepositoryTests {
    @Test func get_shouldCallRemoteFeatureFlagValue_inSdk() async throws {
        var timeoutUsed: TimeInterval?
        var actionTask: Task<Void, Error>?
        var completionCalledWithResult: Result<Int, Error>?

        func completeWithResult(_ result: Result<Int, Error>) -> Void {
            completionCalledWithResult = result
        }

        let expectedValue = Int.random()
        let sut = RemoteFeatureFlagRepository(
            megaSdk: MockRemoteFlagSdk(
                remoteFeatureFlagValue: [
                    "existingKey": expectedValue
                ]
            ),
            withAsyncThrowingValueWithTimeout: { timeout, action in
                timeoutUsed = timeout
                action(completeWithResult)
                try await actionTask?.value
                return (try? completionCalledWithResult?.get()) ?? -1
            },
            runInUserInitiatedTask: { operation in
                actionTask = Task { await operation() }
            }
        )

        let getTask = Task {
            let result = try await sut.get(for: "existingKey")
            #expect(result == expectedValue)
        }

        try await getTask.value

        #expect(timeoutUsed == 3)

        switch completionCalledWithResult {
        case .success(let success):
            #expect(success == expectedValue)
        default:
            Issue.record("Expected to complete with success")
        }
    }
}

private final class MockRemoteFlagSdk: MEGASdk, @unchecked Sendable  {
    var _remoteFeatureFlagValue = [String: Int]()
    var _remoteFeatureFlagValueCalls = [String]()

    init(remoteFeatureFlagValue: [String : Int] = [String: Int]()) {
        self._remoteFeatureFlagValue = remoteFeatureFlagValue
        super.init()
    }

    override func remoteFeatureFlagValue(_ flag: String) -> Int {
        _remoteFeatureFlagValueCalls.append(flag)
        return _remoteFeatureFlagValue[flag] ?? -1
    }
}
