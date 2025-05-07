// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol AccountConfirmationRepositoryProtocol {
    func resendSignUpLink(withEmail email: String, name: String) async throws
    func cancelCreateAccount()
    func waitForAccountConfirmationEvent() async
    func querySignupLink(
        with confirmationLinkUrl: String
    ) async throws -> Bool
    func verifyAccount(
        with confirmationLinkUrl: String,
        password: String
    ) async throws -> Bool
}
