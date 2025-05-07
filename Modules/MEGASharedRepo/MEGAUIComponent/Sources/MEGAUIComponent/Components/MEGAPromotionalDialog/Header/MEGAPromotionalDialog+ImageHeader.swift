// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog where HeaderView == EmptyView {
    func imageHeader(
        _ image: Image
    ) -> UpdatedHeaderView<MEGAPromotionalDialogImageHeader> {
        replaceHeaderView {
            MEGAPromotionalDialogImageHeader(
                image: image
            )
        }
    }
}

public struct MEGAPromotionalDialogImageHeader: View {
    public var image: Image

    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(16 / 9, contentMode: .fill)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: TokenRadius.medium
                )
            )
            .padding([.top, .horizontal], TokenSpacing._5)
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
                .imageHeader(
                    Image(systemName: "squareshape.fill")
                )
            }
        }
    }

    return IllustrationHeaderPreview()
}
