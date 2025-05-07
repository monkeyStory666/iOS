// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGACancelSurvey
import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public typealias IsTrial = Bool

public final class SubscriptionPlanDetailsScreenViewModel: ViewModel<SubscriptionPlanDetailsScreenViewModel.Route> {
    public enum Route {
        case cancelSubscription(SubscriptionNotManageableViewModel)
        case cancelSurvey(CancelSurveyScreenViewModel)
        case subscribe
        case dismissed
    }

    @ViewProperty public var subscriptionPlans: [PlanDetailsRowViewModel] = []
    @ViewProperty public var isShowingManageSubscriptionsSheet = false
    @ViewProperty public var isLoading = true

    var isDuplicatedSubscriptionsWarningShown: Bool {
        subscriptionPlans.count > 1
    }

    private let subscriptionPlansFactory: SubscriptionPlansFactory
    private let isMacCatalyst: Bool
    private let externalLinkOpener: any ExternalLinkOpening

    private var cancelSurveyCompletion: (() -> Void)?

    public typealias SubscriptionPlan = PlanDetailsRowViewModel
    public typealias SubscribeAction = () -> Void
    public typealias ManageAction = (
        PaymentMethodEntity?, IsTrial
    ) -> Void
    public typealias CancelAction = (
        CancelSurveyScreenViewModel, PaymentMethodEntity?, IsTrial
    ) -> Void

    public typealias SubscriptionPlansFactory = (
        _ subscribeAction: @escaping SubscribeAction,
        _ manageSubscriptionAction: @escaping ManageAction,
        _ cancelSubscriptionAction: @escaping CancelAction
    ) async -> [PlanDetailsRowViewModel]

    public init(
        subscriptionPlansFactory: @escaping SubscriptionPlansFactory,
        isMacCatalyst: Bool = false,
        externalLinkOpener: any ExternalLinkOpening = MEGAInfrastructure.DependencyInjection.externalLinkOpener
    ) {
        self.subscriptionPlansFactory = subscriptionPlansFactory
        self.isMacCatalyst = isMacCatalyst
        self.externalLinkOpener = externalLinkOpener
        super.init()
    }

    public func onAppear() async {
        await refresh()
    }

    private func refresh() async {
        isLoading = true
        let subscribeAction = { [weak self] in
            guard let self else { return }
            routeTo(.subscribe)
        }

        let cancelAction = { [weak self] cancelSurveyViewModel, paymentMethod, isTrial in
            if DependencyInjection.shouldShowCancelSurvey {
                self?.routeTo(.cancelSurvey(cancelSurveyViewModel))
                self?.cancelSurveyCompletion = { [weak self] in
                    self?.routeTo(nil)
                    self?.manageSubscription(paymentMethod: paymentMethod, isTrial: isTrial)
                    Task { await self?.refresh() }
                }
            } else {
                self?.routeTo(nil)
                self?.manageSubscription(paymentMethod: paymentMethod, isTrial: isTrial)
                Task { await self?.refresh() }
            }
        }

        let manageSubscriptionAction: ManageAction = { [weak self] paymentMethod, isTrial in
            guard let self else { return }

            manageSubscription(paymentMethod: paymentMethod, isTrial: isTrial)
        }

        subscriptionPlans = await subscriptionPlansFactory(
            subscribeAction,
            manageSubscriptionAction,
            cancelAction
        )
        isLoading = false
    }

    private func didCancelSubscriptionForApple() {
        if isMacCatalyst {
            externalLinkOpener.openExternalLink(with: Constants.Link.appStoreSubscriptions)
        } else {
            isShowingManageSubscriptionsSheet = true
        }
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .cancelSurvey(let cancelSurveyScreenViewModel):
            bind(cancelSurveyScreenViewModel) {
                $0.$route.sink { [weak self] route in
                    switch route {
                    case .dismissed:
                        self?.routeTo(nil)
                    case .finished:
                        self?.cancelSurveyCompletion?()
                    default: break
                    }
                }
            }
        default: break
        }
    }

    private func manageSubscription(paymentMethod: PaymentMethodEntity?, isTrial: Bool) {
        switch paymentMethod {
        case .some(let method) where method == .appleAppStore:
            routeTo(nil)
            didCancelSubscriptionForApple()
        case .some(let method) where method == .googlePlayStore:
            routeTo(
                .cancelSubscription(.init(
                    for: .cancelThroughGoogle,
                    isTrial: isTrial
                ))
            )
        default:
            routeTo(
                .cancelSubscription(.init(
                    for: .cancelThroughWeb,
                    isTrial: isTrial
                ))
            )
        }
    }

    public func didTapDismiss() {
        routeTo(.dismissed)
    }

    public func didTapDismissNotManageableSubscriptionSheet() {
        routeTo(nil)
    }
}

public extension SubscriptionPlanDetailsScreenViewModel.Route {
    var isPresentingSubscribe: Bool {
        switch self {
        case .subscribe: true
        default: false
        }
    }

    var isDismissed: Bool {
        switch self {
        case .dismissed: true
        default: false
        }
    }
}
