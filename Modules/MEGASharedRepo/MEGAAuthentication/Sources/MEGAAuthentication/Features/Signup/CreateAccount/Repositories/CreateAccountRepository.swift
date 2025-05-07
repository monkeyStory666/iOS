// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASwift

public final class CreateAccountRepository: CreateAccountRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func createAccount(
        withFirstName firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> String {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }

            sdk.createAccount(
                withEmail: email,
                password: password,
                firstname: firstName,
                lastname: lastName,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success(let request):
                        if let name = request.name {
                            completion(.success(name))
                        } else {
                            completion(.failure(SignUpErrorEntity.nameEmpty))
                        }
                    case .failure(let error):
                        if error.type == .apiEExist {
                            completion(.failure(SignUpErrorEntity.emailAlreadyInUse))
                        } else {
                            completion(.failure(SignUpErrorEntity.generic))
                        }
                    }
                }
            )
        }
    }
}
