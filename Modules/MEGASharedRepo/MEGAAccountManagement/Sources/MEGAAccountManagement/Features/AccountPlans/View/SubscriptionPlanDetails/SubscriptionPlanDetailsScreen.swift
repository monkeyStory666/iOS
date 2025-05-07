// Copyright © 2024 MEGA Limited. All rights reserved.

import CasePaths
import MEGACancelSurvey
import MEGAConnectivity
import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import StoreKit
import SwiftUI

public struct SubscriptionPlanDetailsScreen<T: ViewModifier>: View {
    @StateObject private var viewModel: SubscriptionPlanDetailsScreenViewModel

    private let purchaseScreenNavigationLink: (SubscriptionPlanDetailsScreenViewModel) -> T

    public init(
        viewModel: @autoclosure @escaping () -> SubscriptionPlanDetailsScreenViewModel,
        purchaseScreenNavigationLink: @escaping (SubscriptionPlanDetailsScreenViewModel) -> T
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.purchaseScreenNavigationLink = purchaseScreenNavigationLink
    }

    public var body: some View {
        NavigationViewStack {
            contentView
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(SharedStrings.Localizable.SubscriptionPlanDetails.navigationTitle)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(
                            action: { viewModel.didTapDismiss() },
                            label: { XmarkCloseButton() }
                        )
                    }
                }
                .manageSubscriptionsSheet(isPresented: $viewModel.isShowingManageSubscriptionsSheet)
                .dynamicSheet(
                    unwrap: $viewModel.route
                        .case(/SubscriptionPlanDetailsScreenViewModel.Route.cancelSubscription)
                ) { $childViewModel in
                    NavigationViewStack {
                        SubscriptionNotManageableScreen(viewModel: $childViewModel.wrappedValue)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button {
                                        viewModel.didTapDismissNotManageableSubscriptionSheet()
                                    } label: {
                                        XmarkCloseButton()
                                    }
                                }
                            }
                            .pageBackground()
                    }
                }
                .dynamicSheet(
                    unwrap: $viewModel.route.case(/SubscriptionPlanDetailsScreenViewModel.Route.cancelSurvey)
                ) { $viewModel in
                    CancelSurveyScreen(viewModel: $viewModel.wrappedValue)
                }
                .modifier(purchaseScreenNavigationLink(viewModel))
                .task { await viewModel.onAppear() }
        }
        .noInternetViewModifier()
    }

    @ViewBuilder private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: .zero) {
            if viewModel.isDuplicatedSubscriptionsWarningShown {
                warningView
            }

            ScrollView {
                VStack(spacing: TokenSpacing._5) {
                    ForEach(viewModel.subscriptionPlans) {
                        PlanDetailsRowView(viewModel: $0)
                    }
                }
                .padding(TokenSpacing._5)
            }
        }
    }

    private var warningView: some View {
        MEGABanner(
            subtitle: SharedStrings.Localizable.TwoSubscriptionsActiveWarning.title,
            state: .warning,
            type: .topAlert
        )
        .clipped()
    }
}
