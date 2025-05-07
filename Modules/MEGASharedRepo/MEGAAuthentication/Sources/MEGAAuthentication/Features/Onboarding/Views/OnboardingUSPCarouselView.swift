// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct OnboardingUSPCarouselView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @StateObject private var viewModel: OnboardingViewModel
    
    private let configuration: OnboardingConfiguration
    
    init(
        viewModel: @autoclosure @escaping () -> OnboardingViewModel = DependencyInjection.onboardingViewModel,
        configuration: OnboardingConfiguration
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel())
        self.configuration = configuration
        setupIndicatorColor()
    }
    
    var body: some View {
        carousel
            .onAppear {
                viewModel.currentPageId = configuration.firstCarouselItemId
            }
    }
    
    @ViewBuilder
    private var carousel: some View {
        if configuration.carouselDisplayMode == .largeImage,
           verticalSizeClass == .compact {
            SplitViewCarousel(
                viewModel: viewModel,
                configuration: configuration)
        } else {
            RegularUSPCarouselView(
                viewModel: viewModel,
                configuration: configuration)
        }
    }
    
    private func setupIndicatorColor() {
        UIPageControl.appearance()
            .currentPageIndicatorTintColor = UIColor(TokenColors.Icon.accent.swiftUI)
        UIPageControl.appearance()
            .pageIndicatorTintColor = UIColor(TokenColors.Icon.disabled.swiftUI)
    }
}

private struct RegularUSPCarouselView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let configuration: OnboardingConfiguration
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: TokenSpacing._5) {
                carouselView(proxy.size)
                buttonsView
            }
            .padding(.bottom, TokenSpacing._5)
        }
    }

    func carouselView(_ size: CGSize) -> some View {
        let multiplier: CGFloat = Constants.isPad ? 0.2 : 0.15
        
        return TabView(selection: $viewModel.currentPageId) {
            ForEach(configuration.carouselContent, id: \.id) {
                carouselSlideView($0)
                    .tag($0.id)
                    .maxWidthForWideScreen()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: configuration.carouselViewMaxHeight,
                        alignment: .center)
                    .padding(.bottom, TokenSpacing._13)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
        .tabViewStyle(.page(indexDisplayMode: configuration.carouselCount > 1 ? .automatic : .never))
        .padding(.top, configuration.carouselDisplayMode == .smallImage ? size.height * multiplier : TokenSpacing._5)
    }

    private func setupIndicatorColor() {
        UIPageControl.appearance()
            .currentPageIndicatorTintColor = UIColor(TokenColors.Icon.accent.swiftUI)
        UIPageControl.appearance()
            .pageIndicatorTintColor = UIColor(TokenColors.Icon.disabled.swiftUI)
    }

    var buttonsView: some View {
        VStack(spacing: TokenSpacing._5) {
            #if targetEnvironment(macCatalyst)
            MEGAButton(
                configuration.loginButtonTitle,
                action: viewModel.didTapLogin
            )
            MEGAButton(
                SharedStrings.Localizable.Onboarding.Button.createAccount,
                type: .textOnly,
                action: viewModel.didTapSignUp
            )
            #else
            MEGAButton(
                SharedStrings.Localizable.Onboarding.Button.createAccount,
                action: viewModel.didTapSignUp
            )
            MEGAButton(
                configuration.loginButtonTitle,
                type: .textOnly,
                action: viewModel.didTapLogin
            )
            #endif
        }
        .padding([.horizontal, .bottom], TokenSpacing._5)
        .maxWidthForWideScreen()
    }

    func carouselSlideView(_ content: OnboardingCarouselContent) -> some View {
        InformationLabelView(
            title: content.title,
            subtitle: content.subtitle,
            image: content.image,
            imageSize: configuration.imageSize,
            shouldFixHorizontalSize: configuration.shouldFixCarouselInformationHorizontalSize,
            alignment: .center,
            textAlignment: .center
        )
        .padding(.horizontal, TokenSpacing._5)
    }
}


private struct SplitViewCarousel: View {
    
    @ObservedObject var viewModel: OnboardingViewModel
    let configuration: OnboardingConfiguration
    
    var body: some View {
        VStack(alignment: .center, spacing: TokenSpacing._5) {
            VStack(alignment: .center, spacing: 0) {
                TabView(selection: $viewModel.currentPageId) {
                    ForEach(configuration.carouselContent, id: \.id) { content in
                        carouselSlideView(content)
                            .tag(content.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                pageIndicators
            }
            
            buttons
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .padding(.top, TokenSpacing._14)
        .padding(.bottom, TokenSpacing._1)
    }
    
    private var buttons: some View {
        HStack(spacing: TokenSpacing._5) {
            MEGAButton(
                configuration.loginButtonTitle,
                type: .textOnly,
                action: viewModel.didTapLogin
            )
            
            MEGAButton(
                SharedStrings.Localizable.Onboarding.Button.createAccount,
                action: viewModel.didTapSignUp
            )
        }
    }
    
    private var pageIndicators: some View {
        HStack(spacing: TokenSpacing._5) {
            ForEach(configuration.carouselContent, id: \.id) { content in
                Circle()
                    .fill(viewModel.currentPageId == content.id ? TokenColors.Icon.accent.swiftUI : TokenColors.Icon.disabled.swiftUI)
                    .frame(width: 8, height: 8)
            }
            .padding(.vertical, TokenSpacing._5)
        }
    }
    
    private func carouselSlideView(_ content: OnboardingCarouselContent) -> some View {
        HStack(alignment: .center) {
            content.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            
            VStack(alignment: .center, spacing: TokenSpacing._5) {
                Text(.init(content.title))
                    .font(.title.bold())
                    .foregroundStyle(TokenColors.Text.primary.swiftUI)
                
                Text(.init(content.subtitle))
                    .font(.callout)
                    .foregroundStyle(TokenColors.Text.secondary.swiftUI)
            }
            .multilineTextAlignment(.center)
        }
    }
}
