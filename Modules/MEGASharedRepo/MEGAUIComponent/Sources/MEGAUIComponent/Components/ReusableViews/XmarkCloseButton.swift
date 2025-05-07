// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

/// A styled "X" icon image, typically used to visually represent a close or dismiss action.
///
/// This view displays a resizable 24x24pt "X" icon from the asset catalog.
/// It does not handle user interaction — it's a visual-only element.
/// You can wrap it in a `Button` or `TapGesture` externally to add interactivity.
///
/// - Parameters:
///   - color: The color used to render the icon. Defaults to `TokenColors.Icon.primary.swiftUI`.
public struct XmarkCloseButton: View {
    private let color: Color

    public init(
        color: Color = TokenColors.Icon.primary.swiftUI
    ) {
        self.color = color
    }

    public var body: some View {
        Image("XMediumLightOutline", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .foregroundStyle(color)
    }
}

struct XmarkCloseButton_Previews: PreviewProvider {
    static var previews: some View {
        XmarkCloseButton()
    }
}
