// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension ImageLabel where Icon == Image {
    init(information label: String) {
        self.init(
            text: label,
            textColor: TokenColors.Text.primary.swiftUI,
            icon: { Image.infoCircle },
            iconColor: TokenColors.Text.primary.swiftUI
        )
    }

    init(success label: String) {
        self.init(
            text: label,
            textColor: TokenColors.Text.success.swiftUI,
            icon: { Image.checkMarkCircle },
            iconColor: TokenColors.Text.success.swiftUI
        )
    }

    init(warning label: String) {
        self.init(
            text: label,
            textColor: TokenColors.Text.warning.swiftUI,
            icon: { Image.exclamationMarkCircle },
            iconColor: TokenColors.Text.warning.swiftUI
        )
    }

    init(error label: String) {
        self.init(
            text: label,
            textColor: TokenColors.Text.error.swiftUI,
            icon: { Image.exclamationMarkTriangle },
            iconColor: TokenColors.Text.error.swiftUI
        )
    }
}

public extension ImageLabel {
    init(
        _ text: String,
        textColor: Color = TokenColors.Text.primary.swiftUI,
        iconColor: Color = TokenColors.Text.primary.swiftUI,
        font: Font = .footnote,
        boldText: Bool = false,
        boldImage: Bool = false,
        isHidden: Bool = false,
        icon: @escaping () -> Icon
    ) {
        self.text = text
        self.textColor = textColor
        self.icon = icon
        self.iconColor = iconColor
        self.font = font
        self.boldText = boldText
        self.boldImage = boldImage
        self.isHidden = isHidden
    }
}

struct ImageLabelInitializers_Previews: PreviewProvider {
    static var previews: some View {
        ImageLabel_Previews.previews
    }
}
