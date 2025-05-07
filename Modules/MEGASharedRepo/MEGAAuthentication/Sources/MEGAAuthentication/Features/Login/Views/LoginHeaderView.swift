import MEGADesignToken
import MEGASharedRepoL10n
import SwiftUI

public struct LoginHeaderView: View {
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: TokenSpacing._7) {
            Image("LoginHeroImage", bundle: .module)
                .resizable()
                .frame(width: 72, height: 72)
            
            Text(SharedStrings.Localizable.Login.headerTitle)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
        }
    }
}
