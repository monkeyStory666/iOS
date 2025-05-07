// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAChecklist: View {
    public enum State {
        case `default`
        case hover
        case focus
        case error
        case disabled
    }

    public var state: State = .default

    @Binding public var isChecked: Bool

    public init(
        state: State = .default,
        isChecked: Binding<Bool>
    ) {
        self.state = state
        self._isChecked = isChecked
    }

    public var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 20, height: 20)
        }
        .disabled(state == .disabled)
        .buttonStyle(
            MEGAChecklistButtonStyle(
                isChecked: isChecked,
                state: state
            )
        )
    }
}

struct MEGAChecklistButtonStyle: ButtonStyle {
    let isChecked: Bool
    let state: MEGAChecklist.State

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                backgroundColor(isPressed: configuration.isPressed)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(
                        borderColor(isPressed: configuration.isPressed),
                        lineWidth: 1
                    )
            }
            .overlay {
                Image("CheckSmallRegularOutline", bundle: .module)
                    .frame(width: 16, height: 16, alignment: .center)
                    .foregroundStyle(
                        state == .disabled
                            ? TokenColors.Icon.disabled.swiftUI
                            : TokenColors.Icon.inverse.swiftUI
                    )
                    .opacity(isChecked ? 1 : 0)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        TokenColors.Focus.focus.swiftUI,
                        lineWidth: 4
                    )
                    .opacity(state == .focus ? 1 : 0)
            }
            .contentShape(Rectangle())
    }

    func backgroundColor(isPressed: Bool) -> Color {
        switch (isChecked, state, isPressed) {
        case (false, _, _): .clear
        case (true, .disabled, _):
            TokenColors.Button.disabled.swiftUI
        case (true, _, true):
            TokenColors.Button.primaryPressed.swiftUI
        case (true, .default, _):
            TokenColors.Components.selectionControl.swiftUI
        case (true, .hover, _), (true, .focus, _):
            TokenColors.Button.primaryHover.swiftUI
        case (true, .error, _):
            TokenColors.Support.error.swiftUI
        }
    }

    func borderColor(isPressed: Bool) -> Color {
        switch (isChecked, state, isPressed) {
        case (true, _, _): .clear
        case (false, .disabled, _):
            TokenColors.Button.disabled.swiftUI
        case (false, _, true):
            TokenColors.Button.outlinePressed.swiftUI
        case (false, .default, _):
            TokenColors.Border.strongSelected.swiftUI
        case (false, .hover, _), (false, .focus, _):
            TokenColors.Button.outlineHover.swiftUI
        case (false, .error, _):
            TokenColors.Support.error.swiftUI
        }
    }
}

struct MEGAChecklist_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 64) {
            HStack {
                VStack(spacing: 32) {
                    unchecked(state: .default)
                    unchecked(state: .hover)
                    unchecked(state: .focus)
                    unchecked(state: .error)
                    unchecked(state: .disabled)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                VStack(spacing: 32) {
                    checked(state: .default)
                    checked(state: .hover)
                    checked(state: .focus)
                    checked(state: .error)
                    checked(state: .disabled)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            VStack(spacing: 16) {
                Text("Clickable Previews")
                    .font(.headline.bold())
                HStack {
                    Group {
                        ClickablePreview(state: .default)
                        ClickablePreview(state: .hover)
                        ClickablePreview(state: .focus)
                        ClickablePreview(state: .error)
                    }
                    .frame(maxWidth: .infinity)
                }
                HStack {
                    Group {
                        ClickablePreview(state: .disabled)
                        ClickablePreview(isChecked: true, state: .disabled)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    static func unchecked(state: MEGAChecklist.State = .default) -> some View {
        VStack {
            Text(title(for: state))
                .font(.callout.bold())
            MEGAChecklist(
                state: state,
                isChecked: .constant(false)
            )
        }
    }

    static func checked(state: MEGAChecklist.State = .default) -> some View {
        VStack {
            Text(title(for: state))
                .font(.callout.bold())
            MEGAChecklist(
                state: state,
                isChecked: .constant(true)
            )
        }
    }

    struct ClickablePreview: View {
        @State var isChecked = false

        let state: MEGAChecklist.State

        var body: some View {
            VStack {
                Text(title(for: state))
                    .font(.footnote.bold())
                MEGAChecklist(
                    state: state,
                    isChecked: $isChecked
                )
            }
        }
    }

    static func title(for state: MEGAChecklist.State) -> String {
        switch state {
        case .default: "Default"
        case .hover: "Hover"
        case .focus: "Focus"
        case .error: "Error"
        case .disabled: "Disabled"
        }
    }
}
