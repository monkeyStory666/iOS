// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Foundation
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAccountManagementMocks
import MEGACancelSurvey
import MEGACancelSurveyMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGASharedRepoL10n
import Testing

@MainActor @Suite(.serialized)
struct SubscriptionPlanDetailsScreenViewModelTests {
    @Test func initialState() async {
        let sut = makeSUTWithoutOnAppear()
        #expect(sut.subscriptionPlans.isEmpty)
        #expect(sut.isShowingManageSubscriptionsSheet == false)
        #expect(sut.isLoading)

        await sut.onAppear()

        #expect(sut.isLoading == false)
    }

    @Test func whenOnlyProPlan_shouldNotDisplayWarning() async {
        let sut = await makeSUT(subscriptionPlansFactory: { _, _, _ in [.init(name: "Pro I")]})

        #expect(sut.isDuplicatedSubscriptionsWarningShown == false)
    }

    @Test func whenProAndVpnPlan_shouldDisplayWarning() async {
        let sut = await makeSUT(subscriptionPlansFactory: { _, _, _ in
            [.init(name: "Pro I"), .init(name: "VPN plan")]
        })

        #expect(sut.isDuplicatedSubscriptionsWarningShown)
    }

    @Test func whenButtonActionIsSubscribe_andIsTapped_shouldOpenManageSubsPage() async {
        var subscribeActionSpy: (() -> Void)?
        let sut = await makeSUT(subscriptionPlansFactory: { subscribeAction, _, _ in
            subscribeActionSpy = subscribeAction
            return []
        })

        subscribeActionSpy?()

        #expect(sut.route?.isPresentingSubscribe == true)
    }

    @Test func whenButtonActionIsCancel_andIsTapped_whenOnlyOnePlan_shouldOpenManageSubsPage() async {
        await assert(
            paymentMethod: .appleAppStore,
            isTrial: false,
            plans: [.init(name: "Pro I")],
            assertThat: { sut in
                #expect(sut.isShowingManageSubscriptionsSheet)
                #expect(sut.route == nil)
            }
        )
        await assert(
            paymentMethod: .googlePlayStore,
            isTrial: false,
            plans: [.init(name: "Pro I")],
            assertThat: { sut in
                if case .cancelSubscription(let viewModel) = sut.route {
                    #expect(
                        viewModel.title ==
                        SharedStrings.Localizable.SubscriptionNotManageableScreen
                            .Google.title
                    )
                    #expect(
                        viewModel.subtitle ==
                        SharedStrings.Localizable.SubscriptionNotManageableScreen
                            .Google.subtitle
                    )
                    #expect(
                        viewModel.subscriptionCancelStepsGroups ==
                        SubscriptionNotManageableType.cancelThroughGoogle.groups()
                    )
                } else {
                    Issue.record("Expected to route to cancel subscription")
                }
            }
        )
        await assert(
            paymentMethod: .webClient,
            isTrial: false,
            plans: [.init(name: "Pro I")],
            assertThat: { sut in
            if case .cancelSubscription(let viewModel) = sut.route {
                #expect(
                    viewModel.title ==
                    SharedStrings.Localizable.SubscriptionNotManageableScreen
                        .Web.title
                )
                #expect(
                    viewModel.subtitle ==
                    SharedStrings.Localizable.SubscriptionNotManageableScreen
                        .Web.subtitle
                )
                #expect(
                    viewModel.subscriptionCancelStepsGroups ==
                    SubscriptionNotManageableType.cancelThroughWeb.groups()
                )
            } else {
                Issue.record("Expected to route to cancel subscription")
            }
        })
        await assert(
            paymentMethod: .googlePlayStore,
            isTrial: true,
            plans: [.init(name: "Pro I")],
            assertThat: { sut in
                if case .cancelSubscription(let viewModel) = sut.route {
                    #expect(
                        viewModel.title ==
                        SharedStrings.Localizable.SubscriptionNotManageableScreen
                            .FreeTrial.Google.title
                    )
                    #expect(
                        viewModel.subtitle ==
                        SharedStrings.Localizable.SubscriptionNotManageableScreen
                            .FreeTrial.Google.subtitle
                    )
                    #expect(
                        viewModel.subscriptionCancelStepsGroups ==
                        SubscriptionNotManageableType.cancelThroughGoogle.groups()
                    )
                } else {
                    Issue.record("Expected to route to cancel subscription")
                }
            }
        )
        await assert(
            paymentMethod: .webClient,
            isTrial: true,
            plans: [.init(name: "Pro I")],
            assertThat: { sut in
            if case .cancelSubscription(let viewModel) = sut.route {
                #expect(
                    viewModel.title ==
                    SharedStrings.Localizable.SubscriptionNotManageableScreen
                        .FreeTrial.Web.title
                )
                #expect(
                    viewModel.subtitle ==
                    SharedStrings.Localizable.SubscriptionNotManageableScreen
                        .FreeTrial.Web.subtitle
                )
                #expect(
                    viewModel.subscriptionCancelStepsGroups ==
                    SubscriptionNotManageableType.cancelThroughWeb.groups()
                )
            } else {
                Issue.record("Expected to route to cancel subscription")
            }
        })
    }

    @Test func cancel_whenIsMacCatalyst_andApplePaymentMethod_shouldOpenExternalSubsLink() async {
        var manageActionSpy: ((PaymentMethodEntity?, IsTrial) -> Void)?
        let mockExternalLinkOpener = MockExternalLinkOpener()
        let sut = await makeSUT(
            subscriptionPlansFactory: { _, manageAction, _ in
                manageActionSpy = manageAction
                return [.init(name: "VPN plan")]
            },
            isMacCatalyst: true,
            externalLinkOpener: mockExternalLinkOpener
        )

        manageActionSpy?(.appleAppStore, .random())

        mockExternalLinkOpener.swt.assert(
            .openExternalLink(Constants.Link.appStoreSubscriptions),
            isCalled: .once
        )

        _ = sut
    }

    @MainActor @Test func cancelSurveyBindings_whenCancelSurveyIsDismissed_shouldRouteToNil() async {
        let cancelSurveyViewModel = mockSurveyViewModel
        let sut = makeSUTWithoutOnAppear()
        sut.route = .cancelSurvey(cancelSurveyViewModel)

        cancelSurveyViewModel.route = .dismissed

        #expect(sut.route == nil)
    }

    @Test func cancelSurveyBindings_whenFinished_andPaymentMethodNil_shouldRouteToCancelSubscriptionThroughWeb() async {
        var cancelActionSpy: SubscriptionPlanDetailsScreenViewModel.CancelAction?

        let expectedTrial = Bool.random()
        let sut = await makeSUT(
            subscriptionPlansFactory: { _, _, cancelAction in
                cancelActionSpy = cancelAction
                return []
            }
        )
        await sut.onAppear()

        let mockSurveyViewModel = mockSurveyViewModel
        cancelActionSpy?(mockSurveyViewModel, nil, expectedTrial)

        mockSurveyViewModel.routeTo(.finished)

        if case .cancelSubscription(let cancelSubViewModel) = sut.route {
            let expectedViewModel = SubscriptionNotManageableViewModel(
                for: .cancelThroughWeb,
                isTrial: expectedTrial
            )
            #expect(cancelSubViewModel.title == expectedViewModel.title)
            #expect(cancelSubViewModel.subtitle == expectedViewModel.subtitle)
            #expect(
                cancelSubViewModel.subscriptionCancelStepsGroups ==
                expectedViewModel.subscriptionCancelStepsGroups
            )
        } else {
            Issue.record("Expected to route to cancel subscription")
        }
    }

    @Test func didTapDismiss_shouldRouteToDismiss() {
        let sut = makeSUTWithoutOnAppear()

        sut.didTapDismiss()

        #expect(sut.route?.isDismissed == true)
    }

    @Test func didTapDismissNotManageableSubscriptionSheet_shouldRouteToNil() {
        let sut = makeSUTWithoutOnAppear()

        sut.didTapDismissNotManageableSubscriptionSheet()

        #expect(sut.route == nil)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        subscriptionPlansFactory: @escaping SubscriptionPlanDetailsScreenViewModel
            .SubscriptionPlansFactory = { _, _, _ in []},
        isMacCatalyst: Bool = false,
        externalLinkOpener: any ExternalLinkOpening = MockExternalLinkOpener()
    ) async -> SubscriptionPlanDetailsScreenViewModel {
        let sut = SubscriptionPlanDetailsScreenViewModel(
            subscriptionPlansFactory: subscriptionPlansFactory,
            isMacCatalyst: isMacCatalyst,
            externalLinkOpener: externalLinkOpener
        )

        await sut.onAppear()

        return sut
    }

    private func makeSUTWithoutOnAppear(
        subscriptionPlansFactory: @escaping SubscriptionPlanDetailsScreenViewModel
            .SubscriptionPlansFactory = { _, _, _ in []},
        isMacCatalyst: Bool = false,
        externalLinkOpener: any ExternalLinkOpening = MockExternalLinkOpener()
    ) -> SubscriptionPlanDetailsScreenViewModel {
        SubscriptionPlanDetailsScreenViewModel(
            subscriptionPlansFactory: subscriptionPlansFactory,
            isMacCatalyst: isMacCatalyst,
            externalLinkOpener: externalLinkOpener
        )
    }

    private func assert(
        paymentMethod: PaymentMethodEntity,
        isTrial: Bool,
        plans: [PlanDetailsRowViewModel],
        assertThat assertion: (SubscriptionPlanDetailsScreenViewModel) -> Void,
        line: UInt = #line
    ) async {
        var manageActionSpy: ((PaymentMethodEntity?, IsTrial) -> Void)?
        let sut = await makeSUT(
            subscriptionPlansFactory: { _, manageAction, _ in
                manageActionSpy = manageAction
                return plans
            }
        )

        manageActionSpy?(paymentMethod, isTrial)

        assertion(sut)
    }

    private var mockSurveyViewModel: CancelSurveyScreenViewModel {
        CancelSurveyScreenViewModel(
            options: [],
            subscriptionId: nil,
            cancelSurveyUseCase: MockCancelSurveyUseCase(),
            analyticsTracker: MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking())
        )
    }

    private typealias SubscriptionNotManageableType = SubscriptionNotManageableViewModel.SubscriptionNotManageableType
}
