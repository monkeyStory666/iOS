// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct BackChevron: View {
    public init() {}

    public var body: some View {
        Image(systemName: "chevron.left")
            .foregroundColor(TokenColors.Icon.primary.swiftUI)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
    }
}

struct BackChevron_Previews: PreviewProvider {
    static var previews: some View {
        BackChevron()
    }
}
