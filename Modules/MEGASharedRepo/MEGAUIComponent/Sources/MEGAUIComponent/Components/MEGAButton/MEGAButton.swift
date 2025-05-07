// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAButton: View {
    public let title: (any StringProtocol)?
    public let icon: Image?
    public let iconAlignment: HorizontalAlignment
    public let type: MEGAButtonType
    public let state: MEGAButtonState
    public let action: (() -> Void)?
    
    public init(
        _ title: (any StringProtocol)? = nil,
        icon: Image? = nil,
        iconAlignment: HorizontalAlignment = .leading,
        type: MEGAButtonType = .primary,
        state: MEGAButtonState = .default,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.iconAlignment = iconAlignment
        self.type = type
        self.state = state
        self.action = action
    }
    
    public var body: some View {
        if let title {
            Button(title, action: action ?? {})
                .disabled(!state.isEnabled || action == nil)
                .buttonStyle(.mega(icon: icon, iconAlignment: iconAlignment, type: type, state: state))
        } else {
            Button(action: action ?? {}, label: { icon })
                .disabled(!state.isEnabled || action == nil)
                .buttonStyle(.mega(icon: icon, iconAlignment: iconAlignment, type: type, state: state))
        }
    }
}

public extension ButtonStyle where Self == MEGAButtonStyle {
    static func mega(
        icon: Image? = nil,
        iconAlignment: HorizontalAlignment = .leading,
        type: MEGAButtonType = .primary,
        state: MEGAButtonState = .default
    ) -> MEGAButtonStyle {
        MEGAButtonStyle(
            icon: icon,
            iconAlignment: iconAlignment,
            type: type,
            state: state
        )
    }
}

public enum MEGAButtonType: Equatable {
    case primary
    case secondary
    case outline
    case destructive
    case destructiveText
    case textOnly
    
    var font: Font {
        switch self {
        case .destructiveText: Font.callout
        default: Font.callout.bold()
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .destructiveText: Alignment.leading
        default: Alignment.center
        }
    }
    
    var height: CGFloat {
        switch self {
        case .textOnly: 1
        default: 0
        }
    }
}

public enum MEGAButtonState: Equatable, Sendable {
    case `default`
    case disabled
    case load
    
    public var isEnabled: Bool { self == .default }
}

public struct MEGAButtonStyle: ButtonStyle {
    public typealias `Type` = MEGAButtonType
    public typealias State = MEGAButtonState
    
    public var icon: Image?
    public var iconAlignment: HorizontalAlignment = .leading
    public var type: MEGAButtonType = .primary
    public var state: MEGAButtonState = .default
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        if type == .outline {
            outlineButton(from: configuration)
        } else {
            button(from: configuration)
        }
    }
    
    private func button(from configuration: Self.Configuration) -> some View {
        label(from: configuration)
            .font(type.font)
            .frame(minHeight: 24)
            .padding(TokenSpacing._4)
            .frame(minHeight: 48)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .cornerRadius(8)
    }
    
    private func outlineButton(from configuration: Self.Configuration) -> some View {
        button(from: configuration)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 1)
                    .stroke(
                        outlineColor(isPressed: configuration.isPressed),
                        lineWidth: 2
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
            )
    }
    
    private func label(from configuration: Self.Configuration) -> some View {
        Group {
            if state == .load {
                ProgressView()
                    .tint(foregroundColor(isPressed: configuration.isPressed))
            } else {
                HStack(spacing: TokenSpacing._3) {
                    if iconAlignment == .leading {
                        iconView
                    }
                    configuration.label
                        .overlay(
                            Rectangle()
                                .fill(foregroundColor(isPressed: configuration.isPressed))
                                .frame(height: type.height),
                            alignment: .bottom
                        )
                    if iconAlignment == .trailing {
                        iconView
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: type.alignment)
    }

    @ViewBuilder private var iconView: some View {
        if let icon {
            icon.resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }

    // MARK: - Private
    
    // swiftlint:disable:next cyclomatic_complexity
    private func backgroundColor(isPressed: Bool) -> some View {
        switch (type, state, isPressed) {
        case (.primary, .default, false): TokenColors.Button.primary.swiftUI
        case (.primary, .default, true): TokenColors.Button.primaryPressed.swiftUI
        case (.primary, .disabled, _): TokenColors.Button.disabled.swiftUI
        case (.primary, .load, _): TokenColors.Button.primary.swiftUI
        case (.secondary, .default, false): TokenColors.Button.secondary.swiftUI
        case (.secondary, .default, true): TokenColors.Button.secondaryPressed.swiftUI
        case (.secondary, .disabled, _): TokenColors.Button.disabled.swiftUI
        case (.secondary, .load, _): TokenColors.Button.secondary.swiftUI
        case (.destructive, .default, false): TokenColors.Button.error.swiftUI
        case (.destructive, .default, true): TokenColors.Button.errorPressed.swiftUI
        case (.destructive, .disabled, _): TokenColors.Button.disabled.swiftUI
        case (.destructive, .load, _): TokenColors.Button.error.swiftUI
        case (.textOnly, _, _), (.destructiveText, _, _), (.outline, _, _): Color.clear
        }
    }
    
    private func foregroundColor(isPressed: Bool) -> Color {
        switch (type, state, isPressed) {
        case (.textOnly, .disabled, _): TokenColors.Text.disabled.swiftUI
        case (.destructiveText, .default, false): TokenColors.Text.error.swiftUI
        case (.destructiveText, .default, true): TokenColors.Button.errorPressed.swiftUI
        case (_, .disabled, _): TokenColors.Text.onColorDisabled.swiftUI
        case (.primary, _, _): TokenColors.Text.inverseAccent.swiftUI
        case (.destructive, _, _): TokenColors.Text.onColor.swiftUI
        case (_, .default, false): TokenColors.Text.primary.swiftUI
        case (_, .default, true): TokenColors.Button.primaryPressed.swiftUI
        case (_, .load, _): TokenColors.Text.primary.swiftUI
        default: TokenColors.Text.primary.swiftUI
        }
    }
    
    private func outlineColor(isPressed: Bool) -> Color {
        switch (type, state, isPressed) {
        case (.outline, .default, false): TokenColors.Button.outline.swiftUI
        case (.outline, .default, true): TokenColors.Button.outlinePressed.swiftUI
        case (.outline, .disabled, _): TokenColors.Border.disabled.swiftUI
        case (.outline, .load, _): TokenColors.Button.outline.swiftUI
        default: Color.clear
        }
    }
}

#Preview {
    struct MEGAButtonPreview: View {
        @State var titleWordCount: Int = 2
        @State var icon: Image?
        @State var buttonType: MEGAButtonType = .primary
        @State var state: MEGAButtonState = .default
        
        var body: some View {
            List {
                Section("Preview") {
                    MEGAButton(
                        String.loremIpsum(titleWordCount),
                        icon: icon,
                        type: buttonType,
                        state: state
                    )
                    .listRowInsets(
                        EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 0,
                            trailing: 0
                        )
                    )
                    .listRowBackground(EmptyView())
                }
                
                Section("Configuration") {
                    Stepper(
                        "Title word count: \(titleWordCount)",
                        value: $titleWordCount,
                        in: 0...20
                    )
                    Toggle(
                        "Icon",
                        isOn: Binding(
                            get: { icon != nil },
                            set: { isOn in
                                icon = isOn ? Image(systemName: "plus.circle") : nil
                            }
                        )
                    )
                    Picker("Button type", selection: $buttonType) {
                        Text("Primary")
                            .tag(MEGAButtonType.primary)
                        Text("Secondary")
                            .tag(MEGAButtonType.secondary)
                        Text("Outline")
                            .tag(MEGAButtonType.outline)
                        Text("Destructive")
                            .tag(MEGAButtonType.destructive)
                        Text("Text Only")
                            .tag(MEGAButtonType.textOnly)
                        Text("Text Destructive")
                            .tag(MEGAButtonType.destructiveText)
                    }
                    Picker("Button state", selection: $state) {
                        Text("Default")
                            .tag(MEGAButtonState.default)
                        Text("Disabled")
                            .tag(MEGAButtonState.disabled)
                        Text("Load")
                            .tag(MEGAButtonState.load)
                    }
                }
            }
        }
    }
    
    return MEGAButtonPreview()
}
