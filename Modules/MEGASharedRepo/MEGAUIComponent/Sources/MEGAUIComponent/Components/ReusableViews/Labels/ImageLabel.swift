// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct ImageLabel<Icon: View>: View {
    public var text: String
    public var textColor: Color

    public var icon: () -> Icon
    public var iconColor: Color

    public var font: Font = .footnote

    public var boldText = false
    public var boldImage = false

    public var isHidden = false

    public var body: some View {
        if !isHidden {
            Label(
                title: {
                    Text(text)
                        .foregroundStyle(textColor)
                        .font(boldText ? font.bold() : font)
                },
                icon: {
                    icon()
                        .foregroundStyle(iconColor)
                        .font(boldImage ? font.bold() : font)
                }
            )
        }
    }
}

// swiftlint:disable line_length
struct ImageLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ImageLabel(information: "Must have at least 8 characters")
            ImageLabel(information: "Must have at least 8 characters")
                .boldText()
            ImageLabel("Must have at least 8 characters") {
                Image.checkMarkCircle
            }
            .boldText()
            .iconColor(TokenColors.Text.success.swiftUI)
            ImageLabel(
                warning: "Your password is easy to guess. We suggest trying a stronger combination of characters."
            )
            .boldText()
            ImageLabel(
                error: "Your password is too easy to guess. You need to try a stronger combination of characters."
            )
            .boldText()
            ImageLabel(error: "Must have at least 8 characters")
                .boldText()
            ImageLabel(error: "Password do not match, try again.")
            ImageLabel(success: "Password confirmed")
            ImageLabel(error: "Should be hidden")
                .hide()
        }
    }
}

// swiftlint:enable line_length
