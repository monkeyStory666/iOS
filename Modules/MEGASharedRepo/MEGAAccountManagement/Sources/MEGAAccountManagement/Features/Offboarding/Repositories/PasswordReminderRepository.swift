// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGAInfrastructure
import MEGASwift

public struct PasswordReminderRepository: PasswordReminderRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func passwordReminderBlocked() async throws {
        try await withAsyncThrowingValue { completion in
            sdk.passwordReminderDialogBlocked(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }

    public func passwordReminderSkipped() async throws {
        try await withAsyncThrowingValue { completion in
            sdk.passwordReminderDialogSkipped(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }

    public func passwordReminderSucceeded() async throws {
        try await withAsyncThrowingValue { completion in
            sdk.passwordReminderDialogSucceeded(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }

    public func shouldShowPasswordReminder(atLogout: Bool) async throws -> Bool {
        try await withAsyncThrowingValue { completion in
            sdk.shouldShowPasswordReminderDialog(
                atLogout: atLogout,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success(let request):
                        completion(.success(request.flag))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
    }
}
