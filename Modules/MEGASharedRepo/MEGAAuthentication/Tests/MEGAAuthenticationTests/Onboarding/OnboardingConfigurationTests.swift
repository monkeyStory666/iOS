@testable import MEGAAuthentication
import SwiftUI
import Testing

struct OnboardingConfigurationTests {

    @Suite("Onboarding Carousel")
    struct OnboardingCarousel {
        @Test(arguments: [
            OnboardingConfiguration.OnboardingCarousel.DisplayMode.smallImage,
            .largeImage]
        )
        func displayMode(
            displayMode: OnboardingConfiguration.OnboardingCarousel.DisplayMode
        ) {
            let sut = makeSUT(displayMode: displayMode)
            #expect(sut.carouselDisplayMode == displayMode)
        }
        
        @Test func contentCount() async throws {
            let count = 4
            let sut = makeSUT(
                carouselContent: Array(repeating: OnboardingCarouselContent(
                    title: "Title",
                    subtitle: "Subtitle",
                    image: Image(systemName: "checkmark")
                ), count: count)
            )
            #expect(sut.carouselCount == count)
        }
        
        @Test(arguments: [
            (OnboardingConfiguration.OnboardingCarousel.DisplayMode.smallImage,
             Optional.some(CGSize(width: 80, height: 80))),
            (.largeImage, .none)]
        )
        func imageSize(
            displayMode: OnboardingConfiguration.OnboardingCarousel.DisplayMode,
            expectedSize: CGSize?
        ) {
            let sut = makeSUT(displayMode: displayMode)
            #expect(sut.imageSize == expectedSize)
        }
        
        @Test(arguments: [
            (OnboardingConfiguration.OnboardingCarousel.DisplayMode.smallImage,
             Optional.none),
            (.largeImage, .some(CGFloat.infinity))]
        )
        func carouselViewMaxHeight(
            for displayMode: OnboardingConfiguration.OnboardingCarousel.DisplayMode,
            expectedMaxHeight: CGFloat?
        ) {
            let sut = makeSUT(displayMode: displayMode)
            #expect(sut.carouselViewMaxHeight == expectedMaxHeight)
        }
        
        @Test(arguments: [
            OnboardingConfiguration.OnboardingCarousel.DisplayMode.smallImage,
            .largeImage]
        )
        func shouldFixCarouselInformationHorizontalSize(
            displayMode: OnboardingConfiguration.OnboardingCarousel.DisplayMode
        ) {
            let sut = makeSUT(displayMode: displayMode)
            #expect(sut.shouldFixCarouselInformationHorizontalSize == (displayMode == .smallImage))
        }
        
        @Test func firstCarouselItemId() {
            let carouselContent = OnboardingCarouselContent(
                title: "title",
                subtitle: "subtitle",
                image: Image(systemName: "checkmark"))
            let sut = makeSUT(
                carouselContent: [carouselContent]
            )
            #expect(sut.firstCarouselItemId == carouselContent.id)
        }
    }
    
    private static func makeSUT(
        displayMode: OnboardingConfiguration.OnboardingCarousel.DisplayMode = .smallImage,
        carouselContent: [OnboardingCarouselContent] = [],
        buttonConfiguration: OnboardingConfiguration.ButtonConfiguration = .init(loginTitle: "")
    ) -> OnboardingConfiguration {
        .init(
            carousel: .init(displayMode: displayMode,
                            carouselContent: carouselContent),
            buttonConfiguration: buttonConfiguration
        )
    }
}
