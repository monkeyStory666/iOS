import MEGADesignToken
import SwiftUI

public struct SplashScreenView: View {
    let logo: Image
    let isAutoFill: Bool

    public init(logo: Image, isAutoFill: Bool = false) {
        self.logo = logo
        self.isAutoFill = isAutoFill
    }

    public var body: some View {
        ZStack {
            TokenColors.Background.page.swiftUI
            logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
            if isAutoFill {
                GeometryReader { geo in
                    ProgressView()
                        // Position the progress view in the mid of the center logo and bottom logo
                        // It is not at the 3/4 of the screen height because we need to account for the bottom logo
                        .position(x: geo.size.width / 2, y: (geo.size.height - 60) * 3 / 4)
                }
                
                Image("megaBottomLogo", bundle: .module)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
            } else {
                VStack(spacing: TokenSpacing._17) {
                    ProgressView()
                        // Bottom padding so that progress view is a bit closer to the
                        // to the main app logo than the bottom one, matching design
                        .padding(.bottom, TokenSpacing._17)
                    
                    Image("megaBottomLogo", bundle: .module)
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .transition(.opacity)
            }
            
        }
        .ignoresSafeArea()
    }
}
