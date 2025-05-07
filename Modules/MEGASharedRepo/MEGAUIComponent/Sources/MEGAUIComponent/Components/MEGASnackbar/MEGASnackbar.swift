// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGADesignToken
import SwiftUI

public struct MEGASnackbar: View {
    @State private var offset: CGSize = .zero
    @State private var isDismissed = false
    @State private var willDismiss = false

    public var text: String
    public var showtime: TimeInterval
    public var actionLabel: String?
    public var action: (() -> Void)?
    public var onDismiss: (() -> Void)?

    public init(
        text: String,
        showtime: TimeInterval,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.showtime = showtime
        self.actionLabel = actionLabel
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            if !isDismissed {
                snackbarBody
                    .simultaneousGesture(swipeToDismissGesture)
                    .transition(
                        .move(edge: .bottom)
                            .combined(with: .opacity)
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + showtime) {
                            dismiss()
                        }
                    }
            }
        }
    }

    private var swipeToDismissGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.width < 50 {
                    offset = gesture.translation
                }
            }
            .onEnded { _ in
                if abs(offset.height) > 20 {
                    dismiss()
                } else {
                    offset = .zero
                }
            }
    }

    private func dismiss() {
        guard !willDismiss, !isDismissed else { return }

        willDismiss = true

        if #available(iOS 17.0, *) {
            withAnimation {
                isDismissed = true
            } completion: {
                onDismiss?()
            }
        } else {
            withAnimation {
                isDismissed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss?()
            }
        }
    }

    private var snackbarBody: some View {
        VStack(alignment: .trailing) {
            textLabel
            actionButton
        }
        .padding(TokenSpacing._5)
        .background(
            RoundedRectangle(cornerRadius: TokenRadius.medium)
                .foregroundStyle(TokenColors.Components.toastBackground.swiftUI)
        )
        .maxWidthForWideScreen()
    }

    private var textLabel: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(TokenColors.Text.inverse.swiftUI)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButton: some View {
        Group {
            if let actionLabel {
                Button {
                    action?()
                } label: {
                    Text(actionLabel)
                        .font(.footnote.bold())
                        .foregroundStyle(TokenColors.Link.inverse.swiftUI)
                }
            }
        }
    }
}
