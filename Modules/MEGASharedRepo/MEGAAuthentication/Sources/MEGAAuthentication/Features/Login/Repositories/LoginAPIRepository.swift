// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASdk
import MEGASDKRepo
import MEGASwift

public final class LoginAPIRepository: LoginAPIRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func login(
        with username: String,
        and password: String
    ) async throws -> String {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }

            sdk.login(
                withEmail: username,
                password: password,
                delegate: loginRequestDelegate(completion: completion)
            )
        }
    }

    public func login(
        with username: String,
        and password: String,
        pin: String
    ) async throws -> String {
        try await withAsyncThrowingValue { [weak self] completion in
            guard let self else { return }

            sdk.multiFactorAuthLogin(
                withEmail: username,
                password: password,
                pin: pin,
                delegate: loginRequestDelegate(
                    successCodes: [.apiOk, .apiENoent],
                    completion: completion
                )
            )
        }
    }

    // This method is used in cases of unstable or no network connectivity,
    // where we do not want to wait for fast login completion.
    // This is particularly useful in VPN scenarios.
    public func fastLogin(
        with timeout: TimeInterval?,
        session: String
    ) async throws -> String {
        try await withAsyncThrowingValue(timeout: timeout) { [weak self] completion in
            guard let self else { return }

            sdk.fastLogin(
                withSession: session,
                delegate: loginRequestDelegate(completion: completion)
            )
        }
    }

    public func accountAuth() -> String? {
        sdk.accountAuth()
    }

    public func set(accountAuth: String?) {
        sdk.setAccountAuth(accountAuth)
    }

    public func loadUserData() async throws {
        try await withAsyncThrowingValue(timeout: 5) { [weak self] completion in
            guard let self else { return }

            sdk.getUserData(with: loadUserDataRequestDelegate(with: completion))
        }
    }

    public func logout() async {
        sdk.logout()
    }

    public func resendVerificationEmail() {
        sdk.resendVerificationEmail()
    }

    public func fetchNodes() async throws {
        try await withAsyncThrowingValue(timeout: 5) { [weak self] completion in
            guard let self else { return }

            sdk.fetchNodes(with: RequestDelegate { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }

    // MARK: - Private methods

    private func loginRequestDelegate(
        successCodes: [MEGAErrorType] = [.apiOk],
        completion: @escaping (Result<String, any Error>) -> Void
    ) -> RequestDelegate {
        RequestDelegate(
            successCodes: successCodes
        ) { [weak self] localCompletion in
            switch localCompletion {
            case .success:
                if let self, let session = sdk.dumpSession() {
                    completion(.success(session))
                } else {
                    completion(.failure(LoginErrorEntity.generic))
                }
            case let .failure(error):
                if error.type == .apiEMFARequired {
                    completion(.failure(LoginErrorEntity.twoFactorAuthenticationRequired))
                } else if error.type == .apiEIncomplete {
                    completion(.failure(LoginErrorEntity.accountNotValidated))
                } else if error.type == .apiESid {
                    completion(.failure(LoginErrorEntity.badSession))
                } else if error.type == .apiETooMany {
                    completion(.failure(LoginErrorEntity.tooManyAttempts))
                } else {
                    completion(.failure(LoginErrorEntity.generic))
                }
            }
        }
    }

    private func loadUserDataRequestDelegate(
        with completion: @escaping (Result<Void, any Error>) -> Void
    ) -> RequestDelegate {
        RequestDelegate { [weak self] localCompletion in
            switch localCompletion {
            case .success:
                completion(.success(()))
            case let .failure(error):
                if error.type == .apiEBlocked {
                    let accountSuspension = await self?.observeAccountSuspendedEvent()
                    completion(.failure(LoginErrorEntity.accountSuspended(accountSuspension)))
                } else {
                    completion(.failure(LoadUserDataErrorEntity.generic))
                }
            }
        }
    }

    private func observeAccountSuspendedEvent() async -> AccountSuspensionTypeEntity? {
        let stream = EventStream(sdk: sdk)
        for await event in stream.events {
            guard let suspensionType = AccountSuspensionType(from: event) else { continue }
            stream.stop()
            return suspensionType.toAccountSuspensionTypeEntity()
        }
        return nil
    }
}
