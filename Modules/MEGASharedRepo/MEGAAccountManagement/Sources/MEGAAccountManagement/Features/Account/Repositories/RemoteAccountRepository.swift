// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGASdk
import MEGASDKRepo
import MEGASwift

public enum AccountRepositoryError: Error {
    case emailNotFound
    case userNotFound
    case base64handleNotFound
}

public final class RemoteAccountRepository<SDK: MEGASdk>: RemoteDataRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func fetch() async throws -> AccountEntity {
        try await fetchUserData()

        guard let email = sdk.myEmail else { throw AccountRepositoryError.emailNotFound }
        guard let user = sdk.myUser else { throw AccountRepositoryError.userNotFound }
        guard let base64handle = SDK.base64Handle(forUserHandle: user.handle) else {
            throw AccountRepositoryError.base64handleNotFound
        }

        let firstName = try await userAttribute(for: .firstname)
        let lastname = try await userAttribute(for: .lastname)

        return AccountEntity(
            handle: user.handle,
            base64Handle: base64handle,
            firstName: firstName,
            lastName: lastname,
            email: email
        )
    }

    private func userAttribute(
        for attribute: MEGAUserAttribute
    ) async throws -> String {
        try await withAsyncThrowingValue(in: { completion in
            sdk.getUserAttributeType(attribute, delegate: RequestDelegate(successCodes: [.apiENoent]) { result in
                switch result {
                case .success(let request):
                    completion(.success(request.text ?? ""))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        })
    }

    private func fetchUserData() async throws {
        try await withAsyncThrowingValue(in: { completion in
            sdk.getUserData(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        })
    }
}
