// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct LoadingScreenView: View {
    private let backgroundColor: Color
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let shadowRadius: CGFloat
    private let progressViewScale: CGFloat

    public init(
        backgroundColor: Color = TokenColors.Background.surface1.swiftUI,
        width: CGFloat = 144,
        height: CGFloat = 64,
        cornerRadius: CGFloat = 8,
        shadowRadius: CGFloat = 5,
        progressViewScale: CGFloat = 1.1
    ) {
        self.backgroundColor = backgroundColor
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.progressViewScale = progressViewScale
    }

    public var body: some View {
        backgroundColor
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
            .overlay {
                ProgressView()
                    .scaleEffect(progressViewScale)
            }
    }
}

struct LoadingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreenView()
    }
}
