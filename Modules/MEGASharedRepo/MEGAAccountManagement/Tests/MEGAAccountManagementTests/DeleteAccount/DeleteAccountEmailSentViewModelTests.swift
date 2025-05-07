// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGAAccountManagementMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGAUIComponent
import MEGATest
import Testing

struct DeleteAccountEmailSentViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()
        #expect(sut.route == nil)
    }

    @Test func testListenToLogoutEvents_whenCalledOnce_shouldPollOnlyOnceImmediately() {
        let deleteAccountUseCase = MockDeleteAccountUseCase()
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        sut.listenToLogoutEvents()
        deleteAccountUseCase.swt.assert(.pollForLogout, isCalled: .once)
    }

    @Test func testListenToLogoutEvents_whenCalledMultipleTimes_shouldPollOnlyOnceImmediately() {
        let deleteAccountUseCase = MockDeleteAccountUseCase()
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        sut.listenToLogoutEvents()
        sut.listenToLogoutEvents()
        sut.listenToLogoutEvents()
        deleteAccountUseCase.swt.assert(.pollForLogout, isCalled: .once)
    }

    @Test func testStopListeningToLogoutEvents_whenInvoked_shouldCancelTheTimer() {
        let deleteAccountUseCase = MockDeleteAccountUseCase()
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        sut.listenToLogoutEvents()
        sut.stopListeningToLogoutEvents()
        sut.listenToLogoutEvents()
        deleteAccountUseCase.swt.assert(.pollForLogout, isCalled: .twice)
    }

    @Test func testEmailSentViewModel_whenClosed_shouldDismiss() {
        let sut = makeSUT()
        sut.emailSentViewModel.didTapCloseButton()
        #expect(sut.route == .dismissed)
    }

    @Test func testEmailSentViewModel_whenResendTappedSuccess_shouldSendEmail() async {
        await assertEmailSentViewModel(deleteAccountResult: .success(()), isSnackbarCalledTimes: .once)
    }

    @Test func testEmailSentViewModel_whenResendTappedFailure_shouldNotSendEmail() async {
        await assertEmailSentViewModel(
            deleteAccountResult: .failure(.generic), isSnackbarCalledTimes: 0.times
        )
    }

    // MARK: - Private methods

    private typealias SUT = DeleteAccountEmailSentViewModel

    private func makeSUT(
        pin: String? = nil,
        deleteAccountUseCase: some DeleteAccountUseCaseProtocol = MockDeleteAccountUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer()
    ) -> SUT {
        DeleteAccountEmailSentViewModel(
            pin: pin,
            deleteAccountUseCase: deleteAccountUseCase,
            snackbarDisplayer: snackbarDisplayer
        )
    }

    private func assertEmailSentViewModel(
        deleteAccountResult: Result<Void, DeleteAccountRepository.Error>, isSnackbarCalledTimes expectedCallFrequency: CallFrequency
    ) async {
        let snackbarDisplayer = MockSnackbarDisplayer()
        let deleteAccountUseCase = MockDeleteAccountUseCase(deleteAccountResult: deleteAccountResult)
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase, snackbarDisplayer: snackbarDisplayer)

        await confirmation(
            in: sut.resendButtonStatePublisher
                .scan((nil, nil)) { ($0.1, $1) }
                .filter { $0 == .load && $1 == .default}
        ) {
            sut.emailSentViewModel.primaryButtonPressed()
        }

        deleteAccountUseCase.swt.assert(.deleteAccount(pin: nil), isCalled: .once)
        snackbarDisplayer.swt.assert(
            .display(.init(
                text: SharedStrings.Localizable.EmailConfirmation.DeleteAccount.ToastMessage.success
            )),
            isCalled: expectedCallFrequency
        )
    }
}
