// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

struct CursorView: View {
    @State private var shown = true

    var isError: Bool = false

    var body: some View {
        ZStack {
            Text("|")
                .font(.callout)
                .foregroundStyle(
                    isError
                    ? TokenColors.Text.error.swiftUI
                    : TokenColors.Text.primary.swiftUI
                )
                .opacity(shown ? 1 : 0)
                .task {
                    try? await blinkCursor()
                }
        }
    }

    private func blinkCursor() async throws {
        showCursor(false, withAnimation: .easeInOut(duration: 0.12))
        try await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC) * 0.29))
        showCursor(true, withAnimation: .easeInOut(duration: 0.8))
        try await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC) * 0.8))
        try await blinkCursor()
    }

    @MainActor private func showCursor(
        _ show: Bool,
        withAnimation animation: Animation? = .default
    ) {
        withAnimation(animation) {
            shown = show
        }
    }
}

struct CursorView_Previews: PreviewProvider {
    static var previews: some View {
        CursorView()
    }
}
