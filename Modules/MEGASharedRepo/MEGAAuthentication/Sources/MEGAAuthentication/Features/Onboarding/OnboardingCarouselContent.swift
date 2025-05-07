// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public struct OnboardingCarouselContent: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String
    let image: Image
    
    public init(title: String, subtitle: String, image: Image) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
