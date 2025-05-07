// Copyright © 2025 MEGA Limited. All rights reserved.

@testable import MEGADebugLogger
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGADebugLoggerMocks
import MEGALogger
import MEGALoggerMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGAUIComponent
import Testing

struct DebugLogsScreenViewModelTests {
    @Test func initialState_whenDebugModeIsEnabled() {
        let sut = makeSUT(debugModeUseCase: MockDebugModeUseCase(isDebugModeEnabled: true))

        #expect(sut.toggleState == .on)
        #expect(sut.alertToPresent == nil)
        #expect(sut.emailToCompose == nil)
        #expect(sut.route == nil)
    }

    @Test func initialState_whenDebugModeIsDisabled() {
        let sut = makeSUT(debugModeUseCase: MockDebugModeUseCase(isDebugModeEnabled: false))

        #expect(sut.toggleState == .off)
        #expect(sut.alertToPresent == nil)
        #expect(sut.emailToCompose == nil)
        #expect(sut.route == nil)
    }

    struct ShouldShowArguments {
        let toggleState: MEGAToggle.State
        let expectedValue: Bool
    }

    @Test(
        arguments: [
            ShouldShowArguments(toggleState: .on, expectedValue: true),
            ShouldShowArguments(toggleState: .off, expectedValue: false)
        ]
    ) func shouldShowContactSupport(
        arguments: ShouldShowArguments
    ) {
        let sut = makeSUT()
        sut.toggleState = arguments.toggleState

        #expect(sut.shouldShowContactSupport == arguments.expectedValue)
    }

    @Test(
        arguments: [
            ShouldShowArguments(toggleState: .on, expectedValue: true),
            ShouldShowArguments(toggleState: .off, expectedValue: false)
        ]
    ) func shouldShowViewLogs(
        arguments: ShouldShowArguments
    ) {
        let sut = makeSUT()
        sut.toggleState = arguments.toggleState

        #expect(sut.shouldShowViewLogs == arguments.expectedValue)
    }

    @Test(
        arguments: [
            ShouldShowArguments(toggleState: .on, expectedValue: true),
            ShouldShowArguments(toggleState: .off, expectedValue: false)
        ]
    ) func shouldShowDisclaimer(
        arguments: ShouldShowArguments
    ) {
        let sut = makeSUT()
        sut.toggleState = arguments.toggleState

        #expect(sut.shouldShowDisclaimer == arguments.expectedValue)
    }

    @Test(
        arguments: [
            ShouldShowArguments(toggleState: .on, expectedValue: true),
            ShouldShowArguments(toggleState: .off, expectedValue: false)
        ]
    ) func shouldShowExportLogs(
        arguments: ShouldShowArguments
    ) {
        let sut = makeSUT()
        sut.toggleState = arguments.toggleState

        #expect(sut.shouldShowExportLogs == arguments.expectedValue)
    }

    @Test func onAppear_shouldObserveDebugMode_andRefreshToggleState_andDisplaySnackbarOnEnabled_andSendEvent() {
        let mockDebugModeUseCase = MockDebugModeUseCase()
        let mockTracker = MockAnalyticsTracking()
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            debugModeUseCase: mockDebugModeUseCase,
            snackbarDisplayer: mockSnackbarDisplayer,
            analyticsTracker: mockTracker
        )

        sut.onAppear()

        mockDebugModeUseCase._observeDebugMode.send(false)
        #expect(sut.toggleState == .off)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: disableSnackbarText))
        ])
        mockTracker.swt.assertsEventsEqual(to: [
            .debugLogsScreenView,
            .debugLogsDisabled
        ])

        mockDebugModeUseCase._observeDebugMode.send(true)
        #expect(sut.toggleState == .on)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: disableSnackbarText)),
            .display(.init(text: enableSnackbarText))
        ])
        mockTracker.swt.assertsEventsEqual(to: [
            .debugLogsScreenView,
            .debugLogsDisabled,
            .debugLogsEnabled
        ])

        mockDebugModeUseCase._observeDebugMode.send(true)
        #expect(sut.toggleState == .on)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: disableSnackbarText)),
            .display(.init(text: enableSnackbarText))
        ])
        mockTracker.swt.assertsEventsEqual(to: [
            .debugLogsScreenView,
            .debugLogsDisabled,
            .debugLogsEnabled
        ])

        mockDebugModeUseCase._observeDebugMode.send(false)
        #expect(sut.toggleState == .off)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: disableSnackbarText)),
            .display(.init(text: enableSnackbarText)),
            .display(.init(text: disableSnackbarText))
        ])
        mockTracker.swt.assertsEventsEqual(to: [
            .debugLogsScreenView,
            .debugLogsDisabled,
            .debugLogsEnabled,
            .debugLogsDisabled
        ])
    }

    @Test func onAppear_shouldTrackScreenViewEvent() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.onAppear()

        mockTracker.swt.assertsEventsEqual(to: [.debugLogsScreenView])
    }

    @Test func didTapDismiss_shouldRouteToDismissed() {
        let sut = makeSUT()

        sut.didTapDismiss()

        #expect(sut.route == .dismissed)
    }

    @Test func didTapToggle_whenIsCurrentlyToggledOn_shouldPresentDisableConfirmationAlert() {
        let mockDebugModeUseCase = MockDebugModeUseCase()
        let sut = makeSUT(debugModeUseCase: mockDebugModeUseCase)

        sut.didTapToggle(.on)
        mockDebugModeUseCase.swt.assertActions(shouldBe: [])

        #expect(
            sut.alertToPresent == AlertModel(
                title: SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.title,
                message: SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.message,
                buttons: [
                    .init(SharedStrings.Localizable.cancel, role: .cancel),
                    .init(SharedStrings.Localizable.DebugLogs.Settings.Disable.Alert.action)
                ]
            )
        )

        sut.alertToPresent?.buttons[1].action() // simulate tap

        mockDebugModeUseCase.swt.assertActions(shouldBe: [.toggleDebugMode])
    }

    @Test func didTapToggle_whenIsCurrentlyToggledOff_shouldPresentEnableConfirmationAlert() {
        let mockDebugModeUseCase = MockDebugModeUseCase()
        let sut = makeSUT(debugModeUseCase: mockDebugModeUseCase)

        sut.didTapToggle(.off)
        mockDebugModeUseCase.swt.assertActions(shouldBe: [])

        #expect(
            sut.alertToPresent == AlertModel(
                title: SharedStrings.Localizable.DebugLogs.Settings.Enable.Alert.title,
                message: SharedStrings.Localizable.DebugLogs.Settings.Enable.Alert.message,
                buttons: [
                    .init(SharedStrings.Localizable.cancel, role: .cancel),
                    .init(SharedStrings.Localizable.confirm)
                ]
            )
        )

        sut.alertToPresent?.buttons[1].action() // simulate tap

        mockDebugModeUseCase.swt.assertActions(shouldBe: [.toggleDebugMode])
    }

    @Test func didTapContactSupport_whenSupportNativeMail_shouldPresentContactSupportAlert() async {
        let expectedEmailEntity = EmailEntity(recipients: [.random()], subject: .random(), body: .random())
        let mockEmailUseCase = MockEmailFormatUseCase(createEmailFormat: expectedEmailEntity)
        let sut = makeSUT(emailFormatUseCase: mockEmailUseCase)

        await sut.didTapContactSupport()

        #expect(
            sut.alertToPresent == AlertModel(
                title: SharedStrings.Localizable.DebugLogs.Settings.ContactSupport.Alert.title,
                message: SharedStrings.Localizable.DebugLogs.Settings.ContactSupport.Alert.message,
                buttons: [
                    .init(SharedStrings.Localizable.cancel, role: .cancel),
                    .init(SharedStrings.Localizable.continue)
                ]
            )
        )

        await sut.alertToPresent?.buttons[1].asyncAction?() // simulate tap

        #expect(sut.emailToCompose == expectedEmailEntity)
    }

    @Test func didTapContactSupport_whenDoesNotSupportNativeMail_shouldPresentEmail() async {
        let mockEmailPresenter = MockEmailPresenter()
        let sut = makeSUT(
            supportNativeMail: { false },
            emailPresenter: mockEmailPresenter
        )

        await sut.didTapContactSupport()

        mockEmailPresenter.swt.assertActions(shouldBe: [.presentMailCompose])
    }

    @Test func didTapContactSupport_shouldTrackButtonPressEvent() async {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        await sut.didTapContactSupport()

        mockTracker.swt.assertsEventsEqual(to: [.submitDebugLogsButtonPressed])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        debugModeUseCase: DebugModeUseCaseProtocol = MockDebugModeUseCase(),
        snackbarDisplayer: SnackbarDisplaying = MockSnackbarDisplayer(),
        supportNativeMail: @escaping () -> Bool = { true },
        emailFormatUseCase: EmailFormatUseCaseProtocol? = nil,
        emailPresenter: EmailPresenting? = nil,
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking()
    ) -> DebugLogsScreenViewModel {
        DebugLogsScreenViewModel(
            debugModeUseCase: debugModeUseCase,
            snackbarDisplayer: snackbarDisplayer,
            supportNativeMail: supportNativeMail,
            emailFormatUseCase: emailFormatUseCase,
            emailPresenter: emailPresenter,
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )
    }

    private var enableSnackbarText: String {
        SharedStrings.Localizable.DebugLogs.Settings.Snackbar.enabled
    }

    private var disableSnackbarText: String {
        SharedStrings.Localizable.DebugLogs.Settings.Snackbar.disabled
    }
}
