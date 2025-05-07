// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGADeeplinkHandling
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift

public struct AccountConfirmationDeeplinkHandler: DeeplinkHandling {
    private let accountConfirmationUseCase: any AccountConfirmationUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying
    private let presentAlert: (AlertModel) -> Void
    private let presentLoginPage: () -> Void
    private let logout: () -> Void

    private var deeplinkHandler: (any DeeplinkHandling)?

    public init(
        accountConfirmationUseCase: any AccountConfirmationUseCaseProtocol,
        snackbarDisplayer: any SnackbarDisplaying,
        presentAlert: @escaping (AlertModel) -> Void,
        presentLoginPage: @escaping () -> Void,
        logout: @escaping () -> Void,
        commonBuilder: () -> DeeplinkBuilder = DeeplinkBuilder.init
    ) {
        self.accountConfirmationUseCase = accountConfirmationUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.presentAlert = presentAlert
        self.presentLoginPage = presentLoginPage
        self.logout = logout
        self.deeplinkHandler = DeeplinkBuilder()
            .build(withChildHandlers: [
                commonBuilder()
                    .path { $0.starts(with: "confirm") }
                    .build(handler: startAccountConfirmationFlow(with:)),
                commonBuilder()
                    .fragment { $0?.starts(with: "confirm") == true }
                    .build(handler: startAccountConfirmationFlow(with:))
            ])
    }

    public func canHandle(_ url: URL) -> Bool {
        deeplinkHandler?.canHandle(url) == true
    }

    public func handle(_ url: URL) {
        deeplinkHandler?.handle(url)
    }

    private func startAccountConfirmationFlow(with confirmationURL: URL) {
        Task(priority: .userInitiated) {
            do {
                try await confirmAccount(with: confirmationURL)
            } catch {
                handleConfirmationError(error)
            }
        }
    }

    private func confirmAccount(with confirmationURL: URL) async throws {
        let isConfirmed = try await accountConfirmationUseCase.verifyAccount(
            with: confirmationURL.absoluteString
        )

        if isConfirmed {
            presentLoginPage()
            snackbarDisplayer.display(.init(text: SharedStrings.Localizable.AccountConfirmation.Snackbar.success))
        } else {
            presentConfirmationInvalidError()
        }
    }

    private func handleConfirmationError(_ error: any Error) {
        if isError(error, equalTo: AccountVerificationError.loggedIntoDifferentAccount) {
            presentAlert(
                .init(
                    title: SharedStrings.Localizable.AccountConfirmation.LoggedInDifferentAccount.title,
                    message: SharedStrings.Localizable.AccountConfirmation.LoggedInDifferentAccount.message,
                    buttons: [
                        .init(SharedStrings.Localizable.logOut) { logout() },
                        .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                    ]
                )
            )
        } else if isError(error, equalTo: AccountVerificationError.alreadyVerifiedOrCanceled) {
            presentConfirmationInvalidError()
        } else {
            presentConfirmationInvalidError()
        }
    }


    private func presentConfirmationInvalidError() {
        presentAlert(
            .init(
                title: SharedStrings.Localizable.AccountConfirmation.InvalidLink.title,
                message: SharedStrings.Localizable.AccountConfirmation.InvalidLink.message,
                buttons: [
                    .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                ]
            )
        )
    }
}
