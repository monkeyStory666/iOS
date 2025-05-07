// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

#Preview {
    struct PlainHeaderPreview: View {
        @State var sheetPresented = true
        @State var headlineWordCount = 2
        @State var smallTitleWordCount = 4
        @State var bodyWordCount = 80

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
            }
        }
    }

    return PlainHeaderPreview()
}
