// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog where HeaderView == EmptyView {
    func fullImageHeader(
        _ image: Image,
        backgroundColor: Color = TokenColors.Icon.primary.swiftUI
    ) -> UpdatedHeaderView<MEGAPromotionalDialogFullImageHeader> {
        var newDialog = self
        newDialog.ignoreSafeAreaEdges = .top
        newDialog.hasCloseButtonOverlay = true
        return newDialog.replaceHeaderView {
            MEGAPromotionalDialogFullImageHeader(
                image: image,
                backgroundColor: backgroundColor
            )
        }
    }
}

public struct MEGAPromotionalDialogFullImageHeader: View {
    public var image: Image
    public var backgroundColor: Color

    public init(
        image: Image,
        backgroundColor: Color = TokenColors.Icon.primary.swiftUI
    ) {
        self.image = image
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        image
            .resizable()
            .aspectRatio(3 / 2, contentMode: .fill)
            .ignoresSafeArea(.all, edges: .all)
            .background(backgroundColor)
    }
}

#Preview {
    struct FullImageHeaderPreview: View {
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
                .updatedToolbarView { currentToolbar in
                    VStack(alignment: .leading, spacing: TokenSpacing._5) {
                        currentToolbar
                        HStack(spacing: TokenSpacing._3) {
                            MEGAChecklist(isChecked: .constant(false))
                            Text("Do not remind again")
                                .font(.footnote)
                                .foregroundStyle(TokenColors.Text.primary.swiftUI)
                        }
                        .padding(.horizontal, TokenSpacing._5)
                    }
                }
                .fullImageHeader(
                    Image(systemName: "squareshape.fill")
                )
            }
        }
    }

    return FullImageHeaderPreview()
}
