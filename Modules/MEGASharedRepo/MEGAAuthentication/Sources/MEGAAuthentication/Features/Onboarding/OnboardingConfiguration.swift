import Foundation
import MEGASharedRepoL10n
import SwiftUI

public struct OnboardingConfiguration {
    public struct OnboardingCarousel {
        public enum DisplayMode {
            case smallImage
            case largeImage
        }

        let displayMode: DisplayMode
        let carouselContent: [OnboardingCarouselContent]
        
        public init(
            displayMode: DisplayMode,
            carouselContent: [OnboardingCarouselContent]
        ) {
            self.carouselContent = carouselContent
            self.displayMode = displayMode
        }
    }
    
    public struct ButtonConfiguration {
        let loginTitle: String
        
        public init(loginTitle: String) {
            self.loginTitle = loginTitle
        }
    }
    
    private let carousel: OnboardingCarousel
    private let buttonConfiguration: ButtonConfiguration
    
    public init(
        carousel: OnboardingCarousel,
        buttonConfiguration: ButtonConfiguration
    ) {
        self.carousel = carousel
        self.buttonConfiguration = buttonConfiguration
    }
    
    public init(
        onboardingCarouselContent: [OnboardingCarouselContent]
    ) {
        self.carousel = .init(
            displayMode: .smallImage,
            carouselContent: onboardingCarouselContent)
        self.buttonConfiguration = .init(
            loginTitle: SharedStrings.Localizable.Onboarding.Button.login)
    }
}

public extension OnboardingConfiguration {
    var carouselDisplayMode: OnboardingCarousel.DisplayMode {
        carousel.displayMode
    }
    
    var carouselContent: [OnboardingCarouselContent] {
        carousel.carouselContent
    }
    
    var carouselCount: Int {
        carouselContent.count
    }
    
    var carouselViewMaxHeight: CGFloat? {
        switch carouselDisplayMode {
        case .smallImage: nil
        case .largeImage: .infinity
        }
    }
    
    var imageSize: CGSize? {
        switch carouselDisplayMode {
        case .smallImage: .init(width: 80, height: 80)
        case .largeImage: nil
        }
    }
    
    var shouldFixCarouselInformationHorizontalSize: Bool {
        carouselDisplayMode == .smallImage
    }
    
    var loginButtonTitle: String {
        buttonConfiguration.loginTitle
    }
    
    var firstCarouselItemId: UUID? {
        carouselContent.first?.id
    }
}
