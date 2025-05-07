// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import Combine
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGATest
import Testing

@MainActor
struct TwoFactorAuthenticationViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.passcode == Passcode())
        #expect(sut.showLoading == false)
        #expect(sut.disableEditing == false)
        #expect(sut.state == .normal)
        #expect(sut.passcodeText.isEmpty)
        #expect(sut.showKeyboard == false)
    }

    @Test func testOnViewAppear_shouldShowKeyboard() {
        let sut = makeSUT()

        sut.onViewAppear()

        #expect(sut.showKeyboard)
    }

    @Test func testOnViewAppear_shouldTrackScreenView() {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        sut.onViewAppear()

        mockTracker.swt.assertsEventsEqual(to: [.multiFactorAuthScreenView])
    }

    @Test func testUpdatePasscode_whenPasscodeIsDifferent_shouldUpdatePasscodeText() {
        let sut = makeSUT()
        sut.passcode = Passcode(text: "654321")
        sut.passcodeText = "654321"

        sut.updatePasscode(withText: "123456")

        #expect(sut.passcode == Passcode(text: "123456"))
        #expect(sut.passcodeText == "123456")
    }

    @Test func testUpdatePasscode_whenNewPasscodeIs6Digit_shouldVerify() {
        let sut = makeSUT()

        sut.updatePasscode(withText: "123456")

        #expect(sut.showLoading)
        #expect(sut.disableEditing)
        #expect(sut.route == .verify("123456"))
    }

    @Test func testUpdatePasscode_whenNewPasscodeIsLessThan6Digit_shouldNotVerifyYet() {
        let sut = makeSUT()

        sut.updatePasscode(withText: "12345")

        #expect(sut.showLoading == false)
        #expect(sut.disableEditing == false)
        #expect(sut.route == nil)
    }

    @Test func testUpdatePasscode_whenNewPasscodeIsNotEmpty_andStateIsNotNormal_shouldResetState() {
        let sut = makeSUT()
        sut.state = .error

        sut.updatePasscode(withText: "12")

        #expect(sut.state == .normal)
    }

    @Test func testUpdatePasscode_whenNewPasscodeIsEmpty_shouldNotResetStateToNormal() {
        let sut = makeSUT()
        sut.state = .error

        sut.updatePasscode(withText: "")

        #expect(sut.state == .error)
    }

    @Test func testDidVerifySuccessfully_shouldStopLoading_andUpdateStateToSuccess() async {
        let sut = makeSUT()
        sut.showLoading = true
        sut.state = .normal

        await sut.didVerifySuccessfully()

        #expect(sut.showLoading == false)
        #expect(sut.state == .success)
    }

    @Test func testDidVerifySuccessfully_shouldTrackSuccessfulEvent() async {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        await sut.didVerifySuccessfully()

        mockTracker.swt.assertsEventsEqual(to: [.multiFactorAuthSuccessful])
    }

    @Test func testDidVerifyWithWrongPasscode_shouldStopLoading_andUpdateStateToError() async {
        let sut = makeSUT()
        sut.showLoading = true
        sut.state = .normal

        await assertWhenVerifyWithWrongPasscode(
            in: sut,
            beforeRefreshPasscodeText: {
                #expect(sut.showLoading)
                #expect(sut.state == .normal)
            },
            afterRefreshPasscodeText: {
                #expect(sut.showLoading == false)
                #expect(sut.state == .error)
            }
        )
    }

    @Test func testDidVerifyWithWrongPasscode_shouldResetPasscode() async {
        let sut = makeSUT()
        sut.passcodeText = "123456"
        sut.passcode = Passcode(text: "123456")

        sut.didVerifyWithWrongPasscode()

        #expect(sut.passcodeText.isEmpty)
        #expect(sut.passcode == Passcode())
    }

    @Test func testDidVerifyWithWrongPasscode_shouldEnableEditing_andShowKeyboard() async {
        let sut = makeSUT()
        sut.disableEditing = true
        sut.showKeyboard = false

        await assertWhenVerifyWithWrongPasscode(
            in: sut,
            beforeRefreshPasscodeText: {
                #expect(sut.disableEditing)
                #expect(sut.showKeyboard == false)
            },
            afterRefreshPasscodeText: {
                #expect(sut.disableEditing == false)
                #expect(sut.showKeyboard)
            }
        )
    }

    @Test func testDidVerifyWithWrongPasscode_shouldRouteToNil() async {
        let sut = makeSUT()

        await assertWhenVerifyWithWrongPasscode(
            in: sut,
            beforeRefreshPasscodeText: {
                #expect(sut.route?.isVerifying == true)
            },
            afterRefreshPasscodeText: {
                #expect(sut.route == nil)
            }
        )
    }

    @Test func testDidVerifyWithWrongPasscode_shouldTrackFailedEvent() async {
        let mockTracker = MockAnalyticsTracking()
        let sut = makeSUT(analyticsTracker: mockTracker)

        await assertWhenVerifyWithWrongPasscode(
            in: sut,
            beforeRefreshPasscodeText: {
                #expect(mockTracker.trackedEvents.isEmpty)
            },
            afterRefreshPasscodeText: {
                mockTracker.swt.assertsEventsEqual(
                    to: [.multiFactorAuthFailed]
                )
            }
        )
    }

    // MARK: - Test Helpers

    private typealias SUT = TwoFactorAuthenticationViewModel

    private func makeSUT(
        analyticsTracker: MockAnalyticsTracking = MockAnalyticsTracking()
    ) -> SUT {
        TwoFactorAuthenticationViewModel(
            analyticsTracker: MockMegaAnalyticsTracker(
                tracker: analyticsTracker
            )
        )
    }

    /// This assert function is needed to do assertion before and after
    /// passcodeText being reset.
    ///
    /// This is because some actions needs to be done only after passcode text
    /// is refreshed to avoid a bug where the text flickers and
    /// didVerifyWithWrongPasscode being called multiple times because of it
    private func assertWhenVerifyWithWrongPasscode(
        in sut: SUT,
        beforeRefreshPasscodeText assertionBefore: @escaping () -> Void,
        afterRefreshPasscodeText assertionAfter: () -> Void
    ) async {
        sut.routeTo(.verify("123123"))

        await confirmation(
            in: Publishers.CombineLatest(
                sut.$passcodeText.filter(\.isEmpty),
                sut.$showKeyboard.filter { $0 }
            )
        ) {
            assertionBefore()
            sut.didVerifyWithWrongPasscode()
        }

        assertionAfter()
    }
}
