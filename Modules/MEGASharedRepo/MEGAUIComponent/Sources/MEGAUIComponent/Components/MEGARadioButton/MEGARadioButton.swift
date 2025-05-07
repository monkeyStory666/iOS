// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGARadioButton: View {
    public let isSelected: Bool
    public let type: MEGARadioButtonType
    public let state: MEGARadioButtonState
    public let title: String
    public let diameter: CGFloat
    public let action: (() -> Void)?

    public init(
        isSelected: Bool,
        type: MEGARadioButtonType = .default,
        state: MEGARadioButtonState = .normal,
        title: String = "",
        diameter: CGFloat = 20,
        action: (() -> Void)? = nil
    ) {
        self.isSelected = isSelected
        self.type = type
        self.state = state
        self.title = title
        self.diameter = diameter
        self.action = action
    }

    public var body: some View {
        Button(title, action: action ?? {})
            .disabled(state == .disabled || action == nil)
            .buttonStyle(
                .megaRadioButton(
                    isSelected: isSelected,
                    type: type,
                    state: state,
                    diameter: diameter
                )
            )
    }
}

public extension ButtonStyle where Self == MEGARadioButtonStyle {
    static func megaRadioButton(
        isSelected: Bool,
        type: MEGARadioButtonType = .default,
        state: MEGARadioButtonState = .normal,
        diameter: CGFloat = 20
    ) -> MEGARadioButtonStyle {
        MEGARadioButtonStyle(
            isSelected: isSelected,
            type: type,
            state: state,
            diameter: diameter
        )
    }
}

public struct MEGARadioButtonStyle: ButtonStyle {
    public let isSelected: Bool
    public let type: MEGARadioButtonType
    public let state: MEGARadioButtonState
    public let diameter: CGFloat

    public init(
        isSelected: Bool,
        type: MEGARadioButtonType = .default,
        state: MEGARadioButtonState = .normal,
        diameter: CGFloat = 20
    ) {
        self.isSelected = isSelected
        self.type = type
        self.state = state
        self.diameter = diameter
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration: configuration)
    }

    private func label(configuration: Configuration) -> some View {
        ZStack(alignment: .center) {
            if state == .focus {
                Circle()
                    .stroke(lineWidth: focusLineWidth)
                    .foregroundStyle(TokenColors.Focus.focus.swiftUI)
                    .frame(width: diameter + focusLineWidth, height: diameter + focusLineWidth)
            }
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundStyle(foregroundColor(configuration))
                .frame(width: diameter, height: diameter)
            if isSelected {
                Circle()
                    .foregroundStyle(foregroundColor(configuration))
                    .frame(width: innerDiameter, height: innerDiameter)
            }
        }
        .background(
            Circle()
                .foregroundStyle(TokenColors.Icon.inverse.swiftUI)
        )
        .padding(padding)
    }

    private var padding: CGFloat { diameter / 10 }
    private var innerDiameter: CGFloat { diameter / 2 }
    private var lineWidth: CGFloat { diameter / 20 }
    private var focusLineWidth: CGFloat { diameter / 5 }

    private func foregroundColor(_ configuration: Configuration) -> Color {
        switch (type, state, configuration.isPressed) {
        case (_, .disabled, _):
            TokenColors.Button.disabled.swiftUI
        case (.default, _, true):
            TokenColors.Button.primaryPressed.swiftUI
        case (.default, .hover, _):
            TokenColors.Button.primaryHover.swiftUI
        case (.default, _, _):
            TokenColors.Button.primary.swiftUI
        case (.error, _, true):
            TokenColors.Button.errorPressed.swiftUI
        case (.error, .hover, _):
            TokenColors.Button.errorHover.swiftUI
        case (.error, _, _):
            TokenColors.Button.error.swiftUI
        }
    }
}

public enum MEGARadioButtonState: CaseIterable {
    case normal
    case focus
    case hover
    case pressed
    case disabled
}

public enum MEGARadioButtonType {
    case `default`
    case error
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isSelected = true

    HStack {
        VStack(spacing: 24) {
            ForEach(MEGARadioButtonState.allCases, id: \.self) { state in
                VStack(spacing: 4) {
                    Text("\(title(type: .default)) - \(title(state: state))")
                        .font(.subheadline)
                    HStack {
                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .default,
                            state: state,
                            diameter: 20
                        ) {
                            isSelected.toggle()
                        }

                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .default,
                            state: state,
                            diameter: 40
                        ) {
                            isSelected.toggle()
                        }

                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .default,
                            state: state,
                            diameter: 60
                        ) {
                            isSelected.toggle()
                        }
                    }
                }
            }
        }
        VStack(spacing: 24) {
            ForEach(MEGARadioButtonState.allCases, id: \.self) { state in
                VStack(spacing: 4) {
                    Text("\(title(type: .error)) - \(title(state: state))")
                        .font(.subheadline)
                    HStack {
                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .error,
                            state: state,
                            diameter: 20
                        ) {
                            isSelected.toggle()
                        }

                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .error,
                            state: state,
                            diameter: 40
                        ) {
                            isSelected.toggle()
                        }

                        staticRadioButtonState(
                            isSelected: isSelected,
                            type: .error,
                            state: state,
                            diameter: 60
                        ) {
                            isSelected.toggle()
                        }
                    }
                }
            }
        }
    }
}

@MainActor
private func staticRadioButtonState(
    isSelected: Bool,
    type: MEGARadioButtonType,
    state: MEGARadioButtonState,
    diameter: CGFloat,
    action: @escaping () -> Void
) -> some View {
    MEGARadioButton(
        isSelected: isSelected,
        type: type,
        state: state,
        diameter: diameter,
        action: action
    )
}

private func title(state: MEGARadioButtonState) -> String {
    switch state {
    case .normal: return "Normal"
    case .focus: return "Focus"
    case .hover: return "Hover"
    case .pressed: return "Pressed"
    case .disabled: return "Disabled"
    }
}

private func title(type: MEGARadioButtonType) -> AttributedString {
    switch type {
    case .default:
        var attributedString = AttributedString("Default")
        attributedString.font = .subheadline.bold()
        return attributedString
    case .error:
        var attributedString = AttributedString("Error")
        attributedString.foregroundColor = .red
        attributedString.font = .subheadline.bold()
        return attributedString
    }
}
#endif
