// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {

    /// Modifies the view to make the background of the TextEditor's scroll content transparent.
    ///
    /// - Returns: A modified view with transparent scroll content for the TextEditor.
    @ViewBuilder func textEditorTransparentScrollContent() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
        } else {
            // Prior to iOS 16, sets UITextView's background color to clear when the view appears.
            onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}
