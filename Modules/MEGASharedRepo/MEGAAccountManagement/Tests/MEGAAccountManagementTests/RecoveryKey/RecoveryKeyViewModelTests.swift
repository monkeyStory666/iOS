// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Foundation
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAccountManagementMocks
import MEGAInfrastructure
import MEGAPresentation
import MEGAPresentationMocks
import MEGATest
import MEGAUIComponent
import MEGASharedRepoL10n
import Testing

struct RecoveryKeyViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.state == .loading)
        #expect(sut.isSavingTextFile == nil)
        #expect(sut.recoveryKeyText == "Recovery Key Placeholder")
        #expect(sut.shouldShowCopyButton == false)
    }

    @Test func testOnAppear_whenRecoveryKeyExist_shouldUpdateStateToLoaded() {
        let expectedKey = String.random(withPrefix: "Recovery Key")
        let mockKeyUseCase = MockRecoveryKeyUseCase(recoveryKey: expectedKey)
        let sut = makeSUT(recoveryKeyUseCase: mockKeyUseCase)

        sut.onAppear()

        #expect(sut.state == .loaded(expectedKey))
    }

    @Test func testOnAppear_whenRecoveryKeyIsNil_shouldUpdateStateToFailed() {
        let mockKeyUseCase = MockRecoveryKeyUseCase(recoveryKey: nil)
        let sut = makeSUT(recoveryKeyUseCase: mockKeyUseCase)

        sut.onAppear()

        #expect(sut.state == .failed)
    }

    @Test func testOnAppear_shouldTrackScreenView() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.onAppear()

        mockTracker.swt.assertsEventsEqual(
            to: [.recoveryKeyScreenView]
        )
    }

    @Test func testDidTapCopy_whenRecoveryKeyLoaded_shouldCopyToClipboard_andDisplaySnackbar() {
        let mockSnackbar = MockSnackbarDisplayer()
        let mockCopy = MockCopyToClipboard()
        let loadedKey = String.random()
        let sut = makeSUT(
            snackbarDisplayer: mockSnackbar,
            copyToClipboard: mockCopy
        )
        sut.state = .loaded(loadedKey)

        sut.didTapCopy()

        mockCopy.swt.assertActions(shouldBe: [.copy(loadedKey)])
        mockSnackbar.swt.assertActions(shouldBe: [.display(.init(
            text: SharedStrings.Localizable.ExportRecoveryKey.Snackbar.copied
        ))])
    }

    @Test func testDidTapCopy_whenRecoveryKeyLoaded_shouldNotifyKeyExported() {
        let mockUseCase = MockRecoveryKeyUseCase()
        let sut = makeSUT(recoveryKeyUseCase: mockUseCase)
        sut.state = .loaded(.random())

        sut.didTapCopy()

        mockUseCase.swt.assert(.keyExported, isCalled: .once)
    }

    @Test func testDidTapCopy_whenRecoveryKeyNotLoaded_shouldNotCopyToClipboard_norDisplaySnackbar() {
        let mockSnackbar = MockSnackbarDisplayer()
        let mockCopy = MockCopyToClipboard()
        let sut = makeSUT(
            snackbarDisplayer: mockSnackbar,
            copyToClipboard: mockCopy
        )
        sut.state = .loading

        sut.didTapCopy()

        mockCopy.swt.assertActions(shouldBe: [])
        mockSnackbar.swt.assertActions(shouldBe: [])
    }

    @Test func testDidTapSaveToDevice_shouldUpdateIsSavingTextFile() {
        let expectedURL = URL.random
        let mockTextFileFromString = MockTextFileFromString(textFile: expectedURL)
        let sut = makeSUT(textFileFromString: mockTextFileFromString)

        sut.didTapSaveToDevice()

        #expect(sut.isSavingTextFile == expectedURL)
    }

    @Test func testDidFinishExportingFile_whenSavedBeforeDismiss_shouldDisplaySnackbar() {
        let mockSnackbar = MockSnackbarDisplayer()
        let sut = makeSUT(snackbarDisplayer: mockSnackbar)

        sut.didDismissSaveSheet(isCompleted: true)

        mockSnackbar.swt.assertActions(shouldBe: [.display(.init(
            text: SharedStrings.Localizable.ExportRecoveryKey.Snackbar.saved
        ))])
    }

    @Test func testDidFinishExportingFile_whenDismissedWithoutSaving_shouldNotDisplaySnackbar() {
        let mockSnackbar = MockSnackbarDisplayer()
        let sut = makeSUT(snackbarDisplayer: mockSnackbar)

        sut.didDismissSaveSheet(isCompleted: false)

        mockSnackbar.swt.assertActions(shouldBe: [])
    }

    @Test func testDidFinishExportingFile_whenSavedBeforeDismissed_shouldNotifyKeyExported() {
        let mockUseCase = MockRecoveryKeyUseCase()
        let sut = makeSUT(recoveryKeyUseCase: mockUseCase)

        sut.didDismissSaveSheet(isCompleted: true)

        mockUseCase.swt.assert(.keyExported, isCalled: .once)
    }

    @Test func testSaveButtonStates() {
        func assert(
            whenState state: LoadableViewState<String>,
            andIsSavingTextFile textFile: URL?,
            saveButonStateShouldBe expectedSaveButtonState: MEGAButtonStyle.State,
            line: UInt = #line
        ) {
            let sut = makeSUT()
            sut.state = state
            sut.isSavingTextFile = textFile

            #expect(sut.saveButtonState == expectedSaveButtonState)
        }

        assert(whenState: .idle, andIsSavingTextFile: nil, saveButonStateShouldBe: .disabled)
        assert(whenState: .failed, andIsSavingTextFile: nil, saveButonStateShouldBe: .disabled)
        assert(whenState: .loading, andIsSavingTextFile: nil, saveButonStateShouldBe: .disabled)
        assert(whenState: .loaded("anyKey"), andIsSavingTextFile: .random, saveButonStateShouldBe: .load)
        assert(whenState: .loaded("anyKey"), andIsSavingTextFile: nil, saveButonStateShouldBe: .default)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        recoveryKeyUseCase: some RecoveryKeyUseCaseProtocol = MockRecoveryKeyUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        copyToClipboard: some CopyToClipboardProtocol = MockCopyToClipboard(),
        textFileFromString: some TextFileFromStringProtocol = MockTextFileFromString(),
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking()
    ) -> RecoveryKeyViewModel {
        RecoveryKeyViewModel(
            snackbarDisplayer: snackbarDisplayer,
            copyToClipboard: copyToClipboard,
            textFileFromString: textFileFromString,
            recoveryKeyUseCase: recoveryKeyUseCase,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )
    }
}

// MARK: - Mocks

final class MockRecoveryKeyUseCase:
    MockObject<MockRecoveryKeyUseCase.Action>,
    RecoveryKeyUseCaseProtocol {
    enum Action: Equatable {
        case recoveryKey
        case keyExported
    }

    var _recoveryKey: String?

    init(recoveryKey: String? = "Mock Key") {
        self._recoveryKey = recoveryKey
    }

    func recoveryKey() -> String? {
        actions.append(.recoveryKey)
        return _recoveryKey
    }

    func keyExported() {
        actions.append(.keyExported)
    }
}

final class MockTextFileFromString:
    MockObject<MockTextFileFromString.Action>,
    TextFileFromStringProtocol {
    enum Action: Equatable {
        case textFile(String)
    }

    var _textFile: URL?

    init(textFile: URL? = nil) {
        self._textFile = textFile
    }

    func textFile(from string: String) -> URL? {
        actions.append(.textFile(string))
        return _textFile
    }
}
