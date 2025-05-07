// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct ListChevron: View {
    public init() {}

    public var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(TokenColors.Icon.secondary.swiftUI)
    }
}

struct ListChevron_Previews: PreviewProvider {
    static var previews: some View {
        ListChevron()
    }
}
