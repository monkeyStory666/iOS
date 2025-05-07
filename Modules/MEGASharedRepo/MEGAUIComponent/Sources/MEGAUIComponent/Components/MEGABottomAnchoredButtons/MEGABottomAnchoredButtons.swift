import MEGADesignToken
import SwiftUI

/// A view representing a group of buttons anchored to the bottom of the screen.
///
/// This view organizes buttons vertically or horizontally and provides an optional title above the buttons.
///
/// - Parameters:
///   - title: An optional title to be displayed above the buttons.
///   - buttons: An array of MEGAButton to be displayed.
///   - buttonsAlignment: The alignment of the buttons within the view, either vertical or horizontal. Default is vertical.
///   - hidesSeparator: A boolean value indicating whether to hide the separator line at the top of the view.
///   - allowMaxWidthForWideScreen: A boolean value indicating whether to allow the view to take up maximum width defined by designers on wide screens. Default is true.
public struct MEGABottomAnchoredButtons: View {
    private let title: String?
    private let buttons: [MEGAButton]
    private let buttonsAlignment: Alignment
    private let hidesSeparator: Bool
    private let allowMaxWidthForWideScreen: Bool

    public init(
        title: String? = nil,
        buttons: [MEGAButton],
        buttonsAlignment: Alignment = .vertical,
        hidesSeparator: Bool = false,
        allowMaxWidthForWideScreen: Bool = true
    ) {
        self.title = title
        self.buttons = buttons
        self.hidesSeparator = hidesSeparator
        self.buttonsAlignment = buttonsAlignment
        self.allowMaxWidthForWideScreen = allowMaxWidthForWideScreen
    }

    /// The body of the view.
    public var body: some View {
        VStack(spacing: TokenSpacing._5) {
            titleView
            alignedButtons
        }
        .if(allowMaxWidthForWideScreen) {
            $0.maxWidthForWideScreen()
        }
        .padding(.horizontal, TokenSpacing._5)
        .padding(.vertical, TokenSpacing._7)
        .frame(maxWidth: .infinity)
        .if(!hidesSeparator, transform: { view in
            view.border(
                width: 0.5, edges: .top,
                color: TokenColors.Border.strong.swiftUI
            )
        })
    }

    @ViewBuilder
    private var titleView: some View {
        if let title, !title.isEmpty {
            Text(.init(title))
                .font(.subheadline)
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
        }
    }

    @ViewBuilder
    private var alignedButtons: some View {
        if buttonsAlignment == .vertical {
            VStack(spacing: TokenSpacing._5) {
                ForEach((0...buttons.count - 1), id: \.self) {
                    buttons[$0]
                }
            }
        } else {
            HStack(spacing: TokenSpacing._6) {
                ForEach((0...buttons.count - 1), id: \.self) {
                    buttons[$0]
                }
            }
        }
    }
}

// MARK: - Nested type

extension MEGABottomAnchoredButtons {
    /// The alignment options for arranging buttons within the view.
    public enum Alignment {
        /// Arranges buttons vertically.
        case vertical
        /// Arranges buttons horizontally.
        case horizontal
    }
}

#Preview {
    MEGABottomAnchoredButtons(
        title: "Preview disclaimer",
        buttons: [.init("Preview button", type: .primary)]
    )
}
