// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import MEGADesignToken
import MEGAUIComponent
import SwiftUI

public struct OnboardingView<LoadingView: View>: View {
    @StateObject private var viewModel: OnboardingViewModel

    private let configuration: OnboardingConfiguration

    @ViewBuilder private let loadingView: () -> LoadingView

    public init(
        viewModel: @autoclosure @escaping () -> OnboardingViewModel = DependencyInjection.onboardingViewModel,
        onboardingCarouselContent: [OnboardingCarouselContent],
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        configuration = .init(
            onboardingCarouselContent: onboardingCarouselContent)
        self.loadingView = loadingView
    }
    
    public init(
        viewModel: @autoclosure @escaping () -> OnboardingViewModel = DependencyInjection.onboardingViewModel,
        configuration: OnboardingConfiguration,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.configuration = configuration
        self.loadingView = loadingView
    }

    public var body: some View {
        ZStack {
            if !viewModel.isHidden {
                OnboardingUSPCarouselView(
                    viewModel: viewModel,
                    configuration: configuration
                )
                .fullScreenCover(
                    unwrap: $viewModel.route.case(/OnboardingViewModel.Route.dataUsageLogin)
                ) { viewModel in
                    DataUsageScreen(viewModel: viewModel.wrappedValue)
                }
                .fullScreenCover(
                    unwrap: $viewModel.route.case(/OnboardingViewModel.Route.dataUsageSignUp)
                ) { viewModel in
                    DataUsageScreen(viewModel: viewModel.wrappedValue)
                }
                .fullScreenCover(
                    unwrap: $viewModel.route.case(/OnboardingViewModel.Route.login)
                ) { viewModel in
                    LoginView(viewModel: viewModel.wrappedValue)
                }
                .fullScreenCover(
                    unwrap: $viewModel.route.case(/OnboardingViewModel.Route.signUp)
                ) { viewModel in
                    CreateAccountView(viewModel: viewModel.wrappedValue)
                }
            } else {
                loadingView()
            }
        }
        .pageBackground()
        .ignoresSafeArea(.container, edges: .top)
        .task { await viewModel.onAppear() }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            onboardingCarouselContent: [
                .init(title: "title1", subtitle: "subtitle1", image: Image(""))
            ],
            loadingView: {
                ProgressView()
            }
        )
    }
}
