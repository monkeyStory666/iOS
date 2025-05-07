// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog {
    func listContent<Content: View>(
        @ViewBuilder _ listContent: @escaping () -> Content
    ) -> UpdatedContentView<VStack<Content>> {
        replaceContentView {
            VStack(spacing: TokenSpacing._5) {
                listContent()
            }
        }
    }
}

#Preview {
    struct ListContentPreview: View {
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
                .listContent {
                    ForEach(0..<6) { _ in
                        MEGAListPreview()
                            .leadingImage(Image(systemName: "square.dashed.inset.filled"))
                    }
                }
            }
        }
    }

    return ListContentPreview()
}
