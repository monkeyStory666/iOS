// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAPromotionalDialog {
    func primaryButton(
        _ button: MEGAButton
    ) -> UpdatedToolbarView<MEGAPromotionalDialogButtonToolbar> {
        replaceToolbarView {
            MEGAPromotionalDialogButtonToolbar(
                primaryButton: button,
                secondaryButton: nil
            )
        }
    }
}

public extension MEGAPromotionalDialog where ToolbarView == MEGAPromotionalDialogButtonToolbar {
    func primaryButton(
        _ button: MEGAButton
    ) -> Self {
        updatedToolbarView {
            MEGAPromotionalDialogButtonToolbar(
                primaryButton: button,
                secondaryButton: $0.secondaryButton
            )
        }
    }

    func secondaryButton(
        _ button: MEGAButton
    ) -> Self {
        updatedToolbarView {
            MEGAPromotionalDialogButtonToolbar(
                primaryButton: $0.primaryButton,
                secondaryButton: button
            )
        }
    }
}

// MARK: - SwiftUI View

public struct MEGAPromotionalDialogButtonToolbar: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    public var primaryButton: MEGAButton?
    public var secondaryButton: MEGAButton?

    public var body: some View {
        if horizontalSizeClass == .regular {
            HStack(spacing: TokenSpacing._5) {
                secondaryButton
                primaryButton
            }
            .padding(.top, TokenSpacing._6)
            .padding(.horizontal, TokenSpacing._5)
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: TokenSpacing._5) {
                primaryButton
                secondaryButton
            }
            .padding(.top, TokenSpacing._6)
            .padding(.horizontal, TokenSpacing._5)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    struct PlainHeaderStylePreview: View {
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
                    ForEach(0..<3) { _ in
                        MEGAListPreview()
                            .leadingImage(Image(systemName: "square.dashed.inset.filled"))
                    }
                }
                .primaryButton(
                    MEGAButton(
                        "Primary action",
                        type: .primary
                    )
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

    return PlainHeaderStylePreview()
}
