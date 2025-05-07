// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Foundation
import MEGAAccountManagementMocks
import MEGAAuthentication
import MEGAUIComponent
import MEGAPresentation
import MEGAPresentationMocks
import MEGATest
import Testing

struct DeleteAccountDetailsViewModelTests {
    @Test func testInitialState_withValidSubscription() async throws {
        let fetchAccountPlanUseCase = MockFetchAccountPlanUseCase(
            fetchAccountDetails: .success(
                .sample(plans: [.sample(isProPlan: true)])
            )
        )
        let sut = makeSUT(fetchAccountPlanUseCase: fetchAccountPlanUseCase)
        try await sut.onAppear()

        #expect(sut.sections == [.otherPlatformSubscription])
        #expect(sut.buttonState == MEGAButtonStyle.State.default)
    }

    @Test func testInitialState_withNoSubscription() async {
        let deleteAccountUseCase = MockDeleteAccountUseCase(
            subscriptionPlatform: .failure(NSError(domain: "", code: 0))
        )
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        try? await sut.onAppear()

        #expect(sut.sections == [])
        #expect(sut.buttonState == MEGAButtonStyle.State.default)
    }

    @Test func testOnAppear_whenInvokedMultipleTimes_shouldShowBannerOnlyOnce() async throws {
        let fetchAccountPlanUseCase = MockFetchAccountPlanUseCase(
            fetchAccountDetails: .success(
                .sample(plans: [.sample(isProPlan: true)])
            )
        )
        let sut = makeSUT(fetchAccountPlanUseCase: fetchAccountPlanUseCase)
        try await sut.onAppear()
        try await sut.onAppear()
        try await sut.onAppear()

        #expect(sut.sections == [.otherPlatformSubscription])
    }

    @Test func testOnAppear_shouldShowCorrectBanner() async throws {
        func assert(
            isProUser: Bool = true,
            with paymentMethods: [PaymentMethodEntity],
            when subscriptionPlatform: SubscriptionPlatform,
            shouldShowSections expectedSections: [DeleteAccountDetailsSectionViewModel],
            line: UInt = #line
        ) async throws {
            let subscriptions: [AccountSubscriptionEntity] = paymentMethods.map{
                .sample(paymentMethod: $0)
            }

            let accountDetails: AccountDetailsEntity = .sample(
                plans: [.sample(isProPlan: isProUser)],
                subscriptions: subscriptions
            )

            let fetchAccountPlanUseCase = MockFetchAccountPlanUseCase(
                fetchAccountDetails: .success(accountDetails)
            )
            let deleteAccountUseCase = MockDeleteAccountUseCase(
                subscriptionPlatform: .success(subscriptionPlatform)
            )
            let sut = makeSUT(
                fetchAccountPlanUseCase: fetchAccountPlanUseCase,
                deleteAccountUseCase: deleteAccountUseCase
            )

            try await sut.onAppear()
            try await sut.onAppear()
            try await sut.onAppear()

            #expect(sut.sections == expectedSections)
        }

        try await assert(
            with: [.googlePlayStore],
            when: .apple,
            shouldShowSections: [.androidSubscription, .appleSubscription]
        )
        try await assert(
            with: [.webClient],
            when: .android,
            shouldShowSections: [.otherPlatformSubscription, .androidSubscription]
        )
        try await assert(
            with: [],
            when: .other,
            shouldShowSections: [.otherPlatformSubscription]
        )
        try await assert(
            isProUser: false,
            with: [.appleAppStore],
            when: .other,
            shouldShowSections: [.appleSubscription]
        )
    }

    @Test func testDidTapClose_whenInvoked_shouldDismiss() {
        let sut = makeSUT()
        sut.didTapClose()
        guard case .dismissed = sut.route else {
            Issue.record("Route should be dismissed")
            return
        }
    }

    @Test func testDidTapDontDelete_whenInvoked_shouldDismiss() {
        let sut = makeSUT()
        sut.didTapDontDelete()
        guard case .dismissed = sut.route else {
            Issue.record("Route should be dismissed")
            return
        }
    }

    @Test func testDidTapContinue_buttonStates_shouldMatch() async {
        let sut = makeSUT()
        let buttonStates = sut.$buttonState.spy()
        await sut.didTapContinue()
        #expect(buttonStates.values == [.load, .default])
    }

    @Test func testDidTapContinue_twoFAError_shouldShowTwoFAScreen() async {
        let deleteAccountUseCase = MockDeleteAccountUseCase(
            deleteAccountResult: .failure(.twoFactorAuthenticationRequired)
        )
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        await sut.didTapContinue()
        guard case .twoFactorAuthentication = sut.route else {
            Issue.record("Should show 2FA screen")
            return
        }
    }

    @Test func testDidTapContinue_whenGenericError_doesNothing() async {
        let deleteAccountUseCase = MockDeleteAccountUseCase(
            deleteAccountResult: .failure(.generic)
        )
        let sut = makeSUT(deleteAccountUseCase: deleteAccountUseCase)
        await sut.didTapContinue()
        #expect(sut.route == nil)
    }

    @Test func testDidTapContinue_twoFACollectedAndDeleteAPISuccess_showEmailSentScreen() async {
        let sut = makeSUT()
        sut.route = .twoFactorAuthentication(
            twoFactorAuthViewModel()
        )

        await confirmation(
            in: sut.$route.filter { $0?.isEmailSent == true },
            "Should route to email sent screen"
        ) {
            await sut.didTapContinue()
        }
    }

    @Test func testTwoFactorBindings_whenDismissed_shouldRouteToNil() {
        let twoFAViewModel = twoFactorAuthViewModel()
        let sut = makeSUT()
        sut.routeTo(.twoFactorAuthentication(twoFAViewModel))

        twoFAViewModel.routeTo(.dismissed)

        #expect(sut.route == nil)
    }

    // MARK: - Private methods

    private typealias SUT = DeleteAccountDetailsViewModel

    private func makeSUT(
        sections: [DeleteAccountDetailsSectionViewModel] = [],
        fetchAccountPlanUseCase: some FetchAccountPlanUseCaseProtocol = MockFetchAccountPlanUseCase(),
        deleteAccountUseCase: some DeleteAccountUseCaseProtocol = MockDeleteAccountUseCase()
    ) -> SUT {
        DeleteAccountDetailsViewModel(
            sections: sections,
            deleteAccountUseCase: deleteAccountUseCase,
            fetchAccountPlanUseCase: fetchAccountPlanUseCase
        )
    }

    private func twoFactorAuthViewModel() -> TwoFactorAuthenticationViewModel {
        TwoFactorAuthenticationViewModel(
            analyticsTracker: nil
        )
    }
}
