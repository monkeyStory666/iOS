// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct PasswordRepository: PasswordRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func isTwoFactorAuthenticationEnabled() async throws -> Bool {
        guard let email = sdk.myEmail else { return false }
        return try await withAsyncThrowingValue { completion in
            sdk.multiFactorAuthCheck(
                withEmail: email,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success(let request):
                        completion(.success(request.flag))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
        }
    }

    public func changePassword(_ newPassword: String) async throws {
        try await withAsyncThrowingValue { completion in
            sdk.changePassword(
                nil,
                newPassword: newPassword,
                delegate: changePasswordRequestDelegate(completion: completion)
            )
        }
    }

    public func changePassword(_ newPassword: String, pin: String) async throws {
        try await withAsyncThrowingValue { completion in
            sdk.multiFactorAuthChangePassword(
                nil,
                newPassword: newPassword,
                pin: pin,
                delegate: changePasswordRequestDelegate(completion: completion)
            )
        }
    }

    // MARK: - Helpers

    private func changePasswordRequestDelegate(completion: @escaping (Result<Void, Error>) -> Void) -> RequestDelegate {
        RequestDelegate { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

