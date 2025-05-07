// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASwift

public final class AccountConfirmationRepository: AccountConfirmationRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func resendSignUpLink(withEmail email: String, name: String) async throws {
        try await withAsyncThrowingValue { completion in
            sdk.resendSignupLink(
                withEmail: email,
                name: name,
                delegate: RequestDelegate { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        switch error.type {
                        case .apiEExist:
                            completion(.failure(ResendSignupLinkError.emailAlreadyInUse))
                        case .apiEFailed:
                            completion(.failure(ResendSignupLinkError.emailConfirmationAlreadyRequested))
                        default:
                            completion(.failure(ResendSignupLinkError.generic))
                        }
                    }
                }
            )
        }
    }

    public func cancelCreateAccount() {
        sdk.cancelCreateAccount()
    }

    public func querySignupLink(
        with confirmationLinkUrl: String
    ) async throws -> Bool {
        try await withAsyncThrowingValue { completion in
            sdk.querySignupLink(
                confirmationLinkUrl,
                delegate: verifyAccountRequestDelegate(completion)
            )
        }
    }

    public func verifyAccount(
        with confirmationLinkUrl: String,
        password: String
    ) async throws -> Bool {
        try await withAsyncThrowingValue { completion in
            sdk.confirmAccount(
                withLink: confirmationLinkUrl,
                password: password,
                delegate: verifyAccountRequestDelegate(completion)
            )
        }
    }

    private func verifyAccountRequestDelegate(
        _ completion: @escaping (Result<Bool, any Error>) -> Void
    ) -> RequestDelegate {
        RequestDelegate { result in
            switch result {
            case .success(let request):
                completion(
                    .success(request.flag)
                )
            case .failure(let error):
                switch error.type {
                case .apiEAccess:
                    completion(.failure(AccountVerificationError.loggedIntoDifferentAccount))
                case .apiEExpired:
                    completion(.failure(AccountVerificationError.alreadyVerifiedOrCanceled))
                default:
                    completion(.failure(error))
                }
            }
        }
    }

    public func waitForAccountConfirmationEvent() async {
        let stream = EventStream(sdk: sdk)
        for await event in stream.events where event.type == .accountConfirmation {
            stream.stop()
        }
    }
}
