// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGABadge: View {
    public let text: String
    public let type: MEGABadgeType
    public let size: MEGABadgeSize
    public let icon: Image?

    public init(
        text: String,
        type: MEGABadgeType,
        size: MEGABadgeSize,
        icon: Image?
    ) {
        self.text = text
        self.type = type
        self.size = size
        self.icon = icon
    }

    public var body: some View {
        HStack(alignment: .center, spacing: TokenSpacing._2) {
            if let icon {
                icon.resizable()
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
            }
            Text(text)
                .font(textFont)
                .foregroundStyle(textColor)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: borderRadius)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: borderRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: 12
        case .regular: 16
        }
    }

    private var iconColor: Color {
        switch type {
        case .megaPrimary:
            TokenColors.Text.onColor.swiftUI
        case .megaSecondary:
            TokenColors.Text.brand.swiftUI
        case .infoPrimary:
            TokenColors.Text.info.swiftUI
        case .infoSecondary:
            TokenColors.Text.secondary.swiftUI
        case .success:
            TokenColors.Text.success.swiftUI
        case .warning:
            TokenColors.Text.warning.swiftUI
        case .error:
            TokenColors.Text.error.swiftUI
        }
    }

    private var textFont: Font {
        switch (type, size) {
        case (.megaPrimary, .small):
            Font.caption.bold()
        case (.megaPrimary, .regular):
            Font.footnote.bold()
        case (.megaSecondary, .small):
            Font.caption2
        case (.megaSecondary, .regular):
            Font.footnote
        case (.infoPrimary, .regular), (.infoSecondary, .regular):
            Font.body
        case (_, .small):
            Font.caption2
        case (_, .regular):
            Font.footnote
        }
    }

    private var textColor: Color {
        switch type {
        case .megaPrimary:
            TokenColors.Text.onColor.swiftUI
        case .megaSecondary:
            TokenColors.Text.brand.swiftUI
        case .infoPrimary:
            TokenColors.Text.info.swiftUI
        case .infoSecondary:
            TokenColors.Text.secondary.swiftUI
        case .success:
            TokenColors.Text.success.swiftUI
        case .warning:
            TokenColors.Text.warning.swiftUI
        case .error:
            TokenColors.Text.error.swiftUI
        }
    }

    private var backgroundColor: Color {
        switch type {
        case .megaPrimary:
            TokenColors.Button.brand.swiftUI
        case .megaSecondary:
            Color.clear
        case .infoPrimary:
            TokenColors.Notifications.notificationInfo.swiftUI
        case .infoSecondary:
            TokenColors.Background.surface3.swiftUI
        case .success:
            TokenColors.Notifications.notificationSuccess.swiftUI
        case .warning:
            TokenColors.Notifications.notificationWarning.swiftUI
        case .error:
            TokenColors.Notifications.notificationError.swiftUI
        }
    }

    private var borderColor: Color {
        switch type {
        case .megaSecondary:
            TokenColors.Button.brand.swiftUI
        default:
            Color.clear
        }
    }

    private var borderRadius: CGFloat {
        switch size {
        case .small: 2
        case .regular: 4
        }
    }

    private var verticalPadding: CGFloat { 4 }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: 4
        case .regular: 6
        }
    }
}

#if DEBUG
private var allTypes: [MEGABadgeType] {
    [
        .infoPrimary,
        .infoSecondary,
        .success,
        .warning,
        .error,
        .megaPrimary,
        .megaSecondary
    ]
}

private var allSizes: [MEGABadgeSize] {
    [.regular, .small]
}

#Preview {
    struct MEGABadgePreview: View {
        @State var textWordCount: Int = 3
        @State var type: MEGABadgeType = .megaPrimary
        @State var size: MEGABadgeSize = .regular
        @State var displayIcon = true

        var body: some View {
            List {
                Section("Examples") {
                    ForEach(allTypes, id: \.self) { type in
                        HStack {
                            ForEach(allSizes, id: \.self) { size in
                                HStack(alignment: .top) {
                                    MEGABadge(
                                        text: description(for: type),
                                        type: type,
                                        size: size,
                                        icon: nil
                                    )
                                    MEGABadge(
                                        text: description(for: type),
                                        type: type,
                                        size: size,
                                        icon: iconImage(for: type)
                                    )
                                }
                            }
                        }
                    }
                }

                Section("Configurable Preview") {
                    MEGABadge(
                        text: String.loremIpsum(textWordCount),
                        type: type,
                        size: size,
                        icon: displayIcon ? iconImage(for: type) : nil
                    )
                }

                Section("Configuration") {
                    Stepper(
                        "Title word count: \(textWordCount)",
                        value: $textWordCount,
                        in: 1...8
                    )
                    Picker("Size", selection: $size) {
                        Text("Small")
                            .tag(MEGABadgeSize.small)
                        Text("Regular")
                            .tag(MEGABadgeSize.regular)
                    }
                    Toggle("Display Icon", isOn: $displayIcon)
                    Picker("Button type", selection: $type) {
                        Text("MEGA Primary")
                            .tag(MEGABadgeType.megaPrimary)
                        Text("MEGA Secondary")
                            .tag(MEGABadgeType.megaSecondary)
                        Text("Info Primary")
                            .tag(MEGABadgeType.infoPrimary)
                        Text("Info Secondary")
                            .tag(MEGABadgeType.infoSecondary)
                        Text("Success")
                            .tag(MEGABadgeType.success)
                        Text("Warning")
                            .tag(MEGABadgeType.warning)
                        Text("Error")
                            .tag(MEGABadgeType.error)

                    }
                }
            }
        }

        func iconImage(for type: MEGABadgeType) -> Image? {
            switch type {
            case .megaPrimary, .megaSecondary:
                Image(systemName: "square.dashed")
            case .infoPrimary, .infoSecondary:
                Image("InfoSmallThinOutline", bundle: .module)
            case .success:
                Image("CheckSmallThinOutline", bundle: .module)
            case .warning:
                Image("AlertCircleSmallThinOutline", bundle: .module)
            case .error:
                Image("AlertTriangleSmallThinOutline", bundle: .module)
            }
        }

        func description(for type: MEGABadgeType) -> String {
            switch type {
            case .megaPrimary:
                return "MEGA1"
            case .megaSecondary:
                return "MEGA2"
            case .infoPrimary:
                return "Info1"
            case .infoSecondary:
                return "Info2"
            case .success:
                return "Success"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            }
        }
    }

    return MEGABadgePreview()
}
#endif
