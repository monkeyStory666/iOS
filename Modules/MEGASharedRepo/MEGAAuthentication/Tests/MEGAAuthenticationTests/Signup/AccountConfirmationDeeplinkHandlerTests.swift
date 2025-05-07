// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGADeeplinkHandling
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGATest
import Testing

struct AccountConfirmationDeeplinkHandlerTests {
    @Test func testCanHandle_whenUrlPathOrFragmentStartsWithConfirm_shouldReturnTrue() {
        let sut = makeSUT()

        #expect(
            sut.canHandle(
                URL(string: "https://mega.nz/confirm\(String.random())")!
            )
        )
        #expect(
            sut.canHandle(
                URL(string: "https://mega.nz/\(String.random())#confirm\(String.random())")!
            )
        )
        #expect(
            sut.canHandle(
                URL(string: "https://mega.nz/\(String.random())")!
            ) == false
        )
    }

    @Test func testHandle_whenConfirmed_shouldQuerySignupLink_withTheCorrectLink_andPresentLoginPage_andSnackbar() async {
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let mockUseCase = MockAccountConfirmationUseCase(
            verifyAccountResult: .success(true)
        )
        let expectedConfirmationLink = validConfirmationLink
        var presentLoginPageCalledTimes = 0
        let sut = makeSUT(
            accountConfirmationUseCase: mockUseCase,
            snackbarDisplayer: mockSnackbarDisplayer,
            presentLoginPage: {
                presentLoginPageCalledTimes += 1
            }
        )

        let result = await confirmation(
            in: mockUseCase.actionsPublisher.compactMap {
                if case .verifyAccount(let confirmationLinkURL) = $0.last {
                    return confirmationLinkURL
                } else { return nil }
            }
        ) {
            sut.handle(expectedConfirmationLink)
        }

        #expect(result == [expectedConfirmationLink.absoluteString])
    }

    @Test func testHandle_whenNotConfirmed_shouldPresentInvalidAlert() async {
        await assert(
            when: .success(false),
            shouldPresentAlert: .init(
                title: SharedStrings.Localizable.AccountConfirmation.InvalidLink.title,
                message: SharedStrings.Localizable.AccountConfirmation.InvalidLink.message,
                buttons: [
                    .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                ]
            )
        )
    }

    @Test func testHandle_whenAlreadyVerifiedOrCanceledError_shouldPresentInvalidAlert() async {
        await assert(
            when: .failure(AccountVerificationError.alreadyVerifiedOrCanceled),
            shouldPresentAlert: .init(
                title: SharedStrings.Localizable.AccountConfirmation.InvalidLink.title,
                message: SharedStrings.Localizable.AccountConfirmation.InvalidLink.message,
                buttons: [
                    .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                ]
            )
        )
    }

    @Test func testHandle_whenUnknownError_shouldPresentInvalidAlert() async {
        await assert(
            when: .failure(ErrorInTest()),
            shouldPresentAlert: .init(
                title: SharedStrings.Localizable.AccountConfirmation.InvalidLink.title,
                message: SharedStrings.Localizable.AccountConfirmation.InvalidLink.message,
                buttons: [
                    .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                ]
            )
        )
    }

    @Test func testHandle_whenLoggedIntoDifferentAccountError_shouldPresentChangeAccountAlert() async {
        await assert(
            when: .failure(AccountVerificationError.loggedIntoDifferentAccount),
            shouldPresentAlert: .init(
                title: SharedStrings.Localizable.AccountConfirmation.LoggedInDifferentAccount.title,
                message: SharedStrings.Localizable.AccountConfirmation.LoggedInDifferentAccount.message,
                buttons: [
                    .init(SharedStrings.Localizable.logOut),
                    .init(SharedStrings.Localizable.GeneralAction.okGotIt, role: .cancel)
                ]
            )
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        accountConfirmationUseCase: any AccountConfirmationUseCaseProtocol = MockAccountConfirmationUseCase(),
        snackbarDisplayer: any SnackbarDisplaying = MockSnackbarDisplayer(),
        presentAlert: @escaping (AlertModel) -> Void = { _ in },
        presentLoginPage: @escaping () -> Void = {},
        logout: @escaping () -> Void = {},
        commonBuilder: () -> DeeplinkBuilder = DeeplinkBuilder.init
    ) -> AccountConfirmationDeeplinkHandler {
        AccountConfirmationDeeplinkHandler(
            accountConfirmationUseCase: accountConfirmationUseCase,
            snackbarDisplayer: snackbarDisplayer,
            presentAlert: presentAlert,
            presentLoginPage: presentLoginPage,
            logout: logout,
            commonBuilder: commonBuilder
        )
    }

    private func assert(
        when verifyAccountResult: Result<Bool, any Error>,
        shouldPresentAlert expectedAlert: AlertModel
    ) async {
        let presentAlertSubject = PassthroughSubject<AlertModel, Never>()
        let sut = makeSUT(
            accountConfirmationUseCase: MockAccountConfirmationUseCase(
                verifyAccountResult: verifyAccountResult
            ),
            presentAlert: {
                presentAlertSubject.send($0)
            }
        )

        let result = await confirmation(in: presentAlertSubject) {
            sut.handle(validConfirmationLink)
        }

        #expect(result == [expectedAlert])
    }

    private var validConfirmationLink: URL {
        URL(string: "https://mega.nz/\(String.random())#confirm\(String.random())")!
    }
}
