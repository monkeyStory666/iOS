// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk
import MEGASDKRepo
import MEGASwift

public final class DeleteAccountRepository: DeleteAccountRepositoryProtocol {
    public enum Error: Swift.Error {
        case generic
        case twoFactorAuthenticationRequired
        case wrongPin
    }

    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func myEmail() -> String? {
        sdk.myEmail
    }

    public func deleteAccount(with pin: String?) async throws {
        if let pin {
            try await multiFactorAuthDeleteAccount(with: pin)
        } else {
            try await deleteAccount()
        }
    }

    public func fetchSubscriptionPlatform() async throws -> SubscriptionPlatform {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }
            sdk.getAccountDetails(with: RequestDelegate { result in
                switch result {
                case .success(let request):
                    guard let accountDetails = request.megaAccountDetails,
                          accountDetails.type != .free else {
                        completion(.failure(Error.generic))
                        return
                    }

                    if accountDetails.subscriptionMethodId == .itunes {
                        completion(.success(.apple))
                    } else if accountDetails.subscriptionMethodId == .googleWallet {
                        completion(.success(.android))
                    } else {
                        completion(.success(.other))
                    }
                case .failure:
                    completion(.failure(Error.generic))
                }
            })
        }
    }

    public func hasLoggedOut() async -> Bool {
        await withAsyncValue { [weak self] completion in
            guard let self else { return }
            sdk.getAccountDetails(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(false))
                case .failure:
                    completion(.success(true))
                }
            })
        }
    }

    private func deleteAccount() async throws {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }
            sdk.cancelAccount(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    if error.type == .apiEMFARequired || error.type == .apiEArgs {
                        completion(.failure(Error.twoFactorAuthenticationRequired))
                    } else {
                        completion(.failure(Error.generic))
                    }
                }
            })
        }
    }

    private func multiFactorAuthDeleteAccount(with pin: String) async throws {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }
            sdk.multiFactorAuthCancelAccount(withPin: pin, delegate: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    if error.type == .apiEFailed {
                        completion(.failure(Error.wrongPin))
                    } else {
                        completion(.failure(Error.generic))
                    }
                }
            })
        }
    }
}
