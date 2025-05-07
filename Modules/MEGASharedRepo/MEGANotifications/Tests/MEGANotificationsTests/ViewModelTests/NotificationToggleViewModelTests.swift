// Copyright © 2024 MEGA Limited. All rights reserved.

import Testing
import MEGANotifications
import MEGANotificationsMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGASharedRepoL10n
import MEGATest

struct NotificationToggleViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.state == .disabled)
    }

    @Test func onAppear_shouldUpdateState_andDisplaySnackbar_basedOnPermission_andPreviousState() async {
        func assert(
            hasPermission: Bool,
            previousState: NotificationToggleViewModel.State,
            expectedState: NotificationToggleViewModel.State,
            expectedSnackbarText: String?,
            line: UInt = #line
        ) async {
            let mockSnackbarDisplayer = MockSnackbarDisplayer()
            let sut = makeSUT(
                useCase: MockNotificationPermissionUseCase(
                    hasPermission: hasPermission
                ),
                snackbarDisplayer: mockSnackbarDisplayer
            )
            sut.state = previousState

            await sut.onAppear()

            #expect(sut.state == expectedState)
            if let expectedSnackbarText {
                mockSnackbarDisplayer.swt.assertActions(shouldBe: [
                    .display(.init(text: expectedSnackbarText))
                ])
            }
        }

        await assert(
            hasPermission: true,
            previousState: .disabled,
            expectedState: .enabled,
            expectedSnackbarText: nil
        )

        await assert(
            hasPermission: false,
            previousState: .disabled,
            expectedState: .disabled,
            expectedSnackbarText: nil
        )

        await assert(
            hasPermission: true,
            previousState: .enabling,
            expectedState: .enabled,
            expectedSnackbarText: SharedStrings.Localizable.Settings.Notifications.Snackbar.enabled
        )

        await assert(
            hasPermission: false,
            previousState: .disabling,
            expectedState: .disabled,
            expectedSnackbarText: SharedStrings.Localizable.Settings.Notifications.Snackbar.disabled
        )
    }

    @Test func toggle_whenCurrentStateDisabled_butAlreadyHasPermission_shouldUpdateState() async {
        let mockSettingsOpener = MockNotificationSettingsOpener()
        let mockUseCase = MockNotificationPermissionUseCase(hasPermission: true)
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            useCase: mockUseCase,
            settingsOpener: mockSettingsOpener,
            snackbarDisplayer: mockSnackbarDisplayer
        )
        sut.state = .disabled

        await sut.toggle()

        mockSettingsOpener.swt.assert(.open, isCalled: 0.times)
        mockUseCase.swt.assertActions(shouldBe: [.hasPermission])
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: SharedStrings.Localizable.Settings.Notifications.Snackbar.enabled))
        ])
        #expect(sut.state == .enabled)
    }

    @Test func toggle_whenCurrentStateEnabled_butDoNotHavePermission_shouldUpdateState() async {
        let mockSettingsOpener = MockNotificationSettingsOpener()
        let mockUseCase = MockNotificationPermissionUseCase(hasPermission: false)
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            useCase: mockUseCase,
            settingsOpener: mockSettingsOpener,
            snackbarDisplayer: mockSnackbarDisplayer
        )
        sut.state = .enabled

        await sut.toggle()

        mockSettingsOpener.swt.assert(.open, isCalled: 0.times)
        mockUseCase.swt.assertActions(shouldBe: [.hasPermission])
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: SharedStrings.Localizable.Settings.Notifications.Snackbar.disabled))
        ])
        #expect(sut.state == .disabled)
    }

    @Test func toggle_whenCurrentStateEnablingOrDisabling_shouldRefreshState() async {
        func assert(
            currentState: NotificationToggleViewModel.State,
            hasPermission: Bool,
            expectedState: NotificationToggleViewModel.State,
            line: UInt = #line
        ) async {
            let mockSettingsOpener = MockNotificationSettingsOpener()
            let mockUseCase = MockNotificationPermissionUseCase(hasPermission: hasPermission)
            let sut = makeSUT(
                useCase: mockUseCase,
                settingsOpener: mockSettingsOpener
            )
            sut.state = currentState

            await sut.toggle()

            mockSettingsOpener.swt.assert(.open, isCalled: 0.times)
            mockUseCase.swt.assertActions(shouldBe: [.hasPermission])
            #expect(sut.state == expectedState)
        }

        await assert(
            currentState: .enabling,
            hasPermission: true,
            expectedState: .enabled
        )
        await assert(
            currentState: .enabling,
            hasPermission: false,
            expectedState: .disabled
        )
        await assert(
            currentState: .disabling,
            hasPermission: true,
            expectedState: .enabled
        )
        await assert(
            currentState: .disabling,
            hasPermission: false,
            expectedState: .disabled
        )
    }

    @Test func toggle_whenCurrentStateEnabled_andHasPermission_shouldOpenSettings() async {
        let mockSettingsOpener = MockNotificationSettingsOpener()
        let mockUseCase = MockNotificationPermissionUseCase(hasPermission: true)
        let sut = makeSUT(
            useCase: mockUseCase,
            settingsOpener: mockSettingsOpener
        )
        sut.state = .enabled

        await sut.toggle()

        mockSettingsOpener.swt.assert(.open, isCalled: .once)
        mockUseCase.swt.assertActions(shouldBe: [.hasPermission])
        #expect(sut.state == .disabling)
    }

    @Test func toggle_whenCurrentStateDisabled_doNotHavePermission_andRequestPermissionSuccessful() async {
        var hasPermissionCalls = 0
        let mockSettingsOpener = MockNotificationSettingsOpener()
        let mockUseCase = MockNotificationPermissionUseCase(
            hasPermission: {
                hasPermissionCalls += 1
                return hasPermissionCalls == 2 ? true : false
            }
        )
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let mockRequestRegistrationUseCase = MockNotificationRequestRegistrationUseCase()
        let sut = makeSUT(
            useCase: mockUseCase,
            settingsOpener: mockSettingsOpener,
            requestRegistrationUseCase: mockRequestRegistrationUseCase,
            snackbarDisplayer: mockSnackbarDisplayer
        )
        sut.state = .disabled
        let stateSpy = sut.$state.spy()

        await sut.toggle()

        mockUseCase.swt.assert(.requestPermission, isCalled: .once)
        mockSettingsOpener.swt.assert(.open, isCalled: 0.times)
        mockRequestRegistrationUseCase.swt.assert(.registerForRemoteNotifications, isCalled: .once)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(text: SharedStrings.Localizable.Settings.Notifications.Snackbar.enabled))
        ])
        #expect(stateSpy.values == [.enabling, .enabled])
    }

    @Test func toggle_whenCurrentStateDisabled_doNotHavePermission_andRequestPermissionFailed() async {
        let mockSettingsOpener = MockNotificationSettingsOpener()
        let mockUseCase = MockNotificationPermissionUseCase(
            requestPermission: .failure(ErrorInTest()),
            hasPermission: false
        )
        let mockRequestRegistrationUseCase = MockNotificationRequestRegistrationUseCase()
        let sut = makeSUT(
            useCase: mockUseCase,
            settingsOpener: mockSettingsOpener,
            requestRegistrationUseCase: mockRequestRegistrationUseCase
        )
        sut.state = .disabled

        await sut.toggle()

        mockUseCase.swt.assertActions(shouldBe: [.hasPermission, .requestPermission])
        mockSettingsOpener.swt.assert(.open, isCalled: .once)
        mockRequestRegistrationUseCase.swt.assert(.registerForRemoteNotifications, isCalled: 0.times)
        #expect(sut.state == .enabling)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        useCase: some NotificationPermissionUseCaseProtocol = MockNotificationPermissionUseCase(),
        settingsOpener: some NotificationSettingsOpening = MockNotificationSettingsOpener(),
        requestRegistrationUseCase: some NotificationRequestRegistrationUseCaseProtocol =
        MockNotificationRequestRegistrationUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer()
    ) -> NotificationToggleViewModel {
        NotificationToggleViewModel(
            useCase: useCase,
            settingsOpener: settingsOpener,
            requestRegistrationUseCase: requestRegistrationUseCase,
            snackbarDisplayer: snackbarDisplayer
        )
    }
}
