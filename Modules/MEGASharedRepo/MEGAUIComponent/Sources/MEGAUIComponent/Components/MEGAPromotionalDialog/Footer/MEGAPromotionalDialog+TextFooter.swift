// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog {
    func footerText(
        _ text: String
    ) -> UpdatedFooterView<MEGAPromotionalDialogTextFooter> {
        replaceFooterView {
            MEGAPromotionalDialogTextFooter(text: AttributedString(text))
        }
    }

    func footerText(
        _ text: AttributedString
    ) -> UpdatedFooterView<MEGAPromotionalDialogTextFooter> {
        replaceFooterView {
            MEGAPromotionalDialogTextFooter(text: text)
        }
    }
}

public struct MEGAPromotionalDialogTextFooter: View {
    public var text: AttributedString

    public init(text: AttributedString) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, TokenSpacing._5)
            .padding(.bottom, TokenSpacing._5)
            .foregroundStyle(TokenColors.Text.secondary.swiftUI)
    }
}

#Preview {
    struct TextFooterPreview: View {
        @State var sheetPresented = true

        var body: some View {
            Button("Preview") {
                sheetPresented = true
            }
            .pageBackground()
            .sheet(isPresented: $sheetPresented) {
                MEGAPromotionalDialogPreview(
                    dismissAction: { sheetPresented = false }
                )
                .footerText(AttributedString(String.loremIpsum(30)))
            }
        }
    }

    return TextFooterPreview()
}
