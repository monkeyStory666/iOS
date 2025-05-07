// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct AccountNameRepository: AccountNameRepositoryProtocol {
    public enum ChangeNameError: Error {
        case failedToChangeFirstName
        case failedToChangeLastName
        case failedToChangeName
    }

    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func changeName(
        firstName: String,
        lastName: String
    ) async throws {
        async let changeFirstName = changeFirstName(firstName)
        async let changeLastName = changeLastName(lastName)

        switch (await changeFirstName, await changeLastName) {
        case (.failure, .failure):
            throw ChangeNameError.failedToChangeName
        case (.failure, _):
            throw ChangeNameError.failedToChangeFirstName
        case (_, .failure):
            throw ChangeNameError.failedToChangeLastName
        default:
            return
        }
    }

    private func changeFirstName(_ firstName: String) async -> Result<MEGARequest, MEGAError> {
        await withAsyncValue { completion in
            sdk.setUserAttributeType(
                .firstname,
                value: firstName,
                delegate: RequestDelegate { result in
                    completion(.success(result))
                }
            )
        }
    }

    private func changeLastName(_ lastName: String) async -> Result<MEGARequest, MEGAError> {
        await withAsyncValue { completion in
            sdk.setUserAttributeType(
                .lastname,
                value: lastName,
                delegate: RequestDelegate { result in
                    completion(.success(result))
                }
            )
        }
    }
}

