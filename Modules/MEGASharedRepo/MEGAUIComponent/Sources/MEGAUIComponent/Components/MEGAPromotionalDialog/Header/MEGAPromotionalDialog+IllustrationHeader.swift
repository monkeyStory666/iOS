// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog where HeaderView == EmptyView {
    func illustrationHeader(
        _ image: Image
    ) -> UpdatedHeaderView<MEGAPromotionalDialogIllustrationHeader> {
        replaceHeaderView {
            MEGAPromotionalDialogIllustrationHeader(
                illustration: image
            )
        }
    }
}

public struct MEGAPromotionalDialogIllustrationHeader: View {
    public var illustration: Image

    public init(illustration: Image) {
        self.illustration = illustration
    }

    public var body: some View {
        illustration
            .resizable()
            .frame(width: 120, height: 120, alignment: .center)
            .padding(.top, TokenSpacing._5)
    }
}

#Preview {
    struct IllustrationHeaderPreview: View {
        @State var sheetPresented = true

        var body: some View {
            Button("Preview") {
                sheetPresented = true
            }
            .pageBackground()
            .sheet(isPresented: $sheetPresented) {
                MEGAPromotionalDialogPreview(
                    headlineWordCount: 2,
                    smallTitleWordCount: 4,
                    bodyWordCount: 48,
                    dismissAction: { sheetPresented = false }
                )
                .listContent {
                    ForEach(0..<4) { _ in
                        MEGAListPreview()
                            .leadingImage(
                                Image(systemName: "square.dashed.inset.filled")
                            )
                    }
                }
                .footerText(String.loremIpsum(24))
                .primaryButton(
                    MEGAButton("Primary action")
                )
                .secondaryButton(
                    MEGAButton(
                        "Secondary action",
                        type: .secondary
                    )
                )
                .illustrationHeader(
                    Image(systemName: "square.dashed.inset.filled")
                )
            }
        }
    }

    return IllustrationHeaderPreview()
}
