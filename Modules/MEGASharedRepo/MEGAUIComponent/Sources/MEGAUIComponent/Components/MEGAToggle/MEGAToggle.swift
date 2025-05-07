// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAToggle: View {
    public enum State: Sendable {
        // swiftlint:disable:next identifier_name
        case on
        case off
        case togglingOn
        case togglingOff

        public var isOn: Bool {
            switch self {
            case .on, .togglingOn: true
            case .off, .togglingOff: false
            }
        }

        public init(isOn: Bool) {
            self = isOn ? .on : .off
        }
    }

    public let state: State
    public let isDisabled: Bool
    public var width: CGFloat

    public var toggleAction: (_ state: State) -> Void

    public var height: CGFloat { width / 2 }
    public var circleDiameter: CGFloat { width / 3 }

    var onIconSize: CGFloat { circleDiameter * 14 / 16 }
    var offIconWidth: CGFloat { circleDiameter * 10 / 16 }
    var capsule: RoundedRectangle { RoundedRectangle(cornerRadius: height * 0.5) }

    public init(
        state: State,
        isDisabled: Bool = false,
        width: CGFloat = 48,
        toggleAction: @escaping (_ state: State) -> Void
    ) {
        self.state = state
        self.isDisabled = isDisabled
        self.width = width
        self.toggleAction = toggleAction
    }

    public var body: some View {
        Button {
            toggleAction(state)
        } label: {
            ZStack {
                capsule
                    .foregroundColor(
                        state.isOn
                            ? primaryColor
                            : TokenColors.Background.page
                                .swiftUI
                    )
                    .overlay { capsule.stroke(primaryColor, lineWidth: 1) }
                    .contentShape(capsule)
                ZStack {
                    HStack {
                        Circle()
                            .foregroundColor(
                                state.isOn
                                    ? TokenColors.Background.page.swiftUI
                                    : primaryColor
                            )
                            .frame(width: circleDiameter, height: circleDiameter)
                            .padding((height - circleDiameter) / 2)
                    }
                    Group {
                        switch state {
                        case .on:
                            Image("CheckSmallRegularOutline", bundle: .module)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: onIconSize, height: onIconSize, alignment: .center)
                        case .off:
                            RoundedRectangle(cornerRadius: onIconSize * 0.5)
                                .frame(
                                    width: offIconWidth,
                                    height: offIconWidth / 5,
                                    alignment: .center
                                )
                        case .togglingOn, .togglingOff:
                            ProgressView()
                                .tint(
                                    state.isOn
                                        ? primaryColor
                                        : TokenColors.Background.page.swiftUI
                                )
                        }
                    }
                    .foregroundColor(
                        state.isOn
                            ? primaryColor
                            : TokenColors.Background.page
                                .swiftUI
                    )
                }
                .frame(maxWidth: .infinity, alignment: state.isOn ? .trailing : .leading)
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(MEGAToggleButtonStyle())
        .disabled(isDisabled)
    }

    var primaryColor: Color {
        isDisabled
            ? TokenColors.Border.disabled.swiftUI
            : TokenColors.Components.selectionControl.swiftUI
    }
}

struct MEGAToggleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Previews

private struct MEGATogglePreview: View {
    @State var state: MEGAToggle.State = .off

    var body: some View {
        MEGAToggle(
            state: state,
            isDisabled: false,
            width: 120,
            toggleAction: { state in
                if case .on = state {
                    changeState(to: .togglingOff)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        changeState(to: .off)
                    }
                } else if case .off = state {
                    changeState(to: .togglingOn)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        changeState(to: .on)
                    }
                }
            }
        )
    }

    private func changeState(to state: MEGAToggle.State) {
        withAnimation {
            self.state = state
        }
    }
}

struct MEGAToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("MEGA Toggle").font(.largeTitle.bold())
            Spacer()
            MEGATogglePreview()
            Spacer()
            HStack {
                VStack(spacing: 24) {
                    Text("Enabled").font(.title3.bold())
                    staticToggle(state: .off, isDisabled: false)
                    staticToggle(state: .togglingOn, isDisabled: false)
                    staticToggle(state: .on, isDisabled: false)
                    staticToggle(state: .togglingOff, isDisabled: false)
                }
                Spacer()
                VStack(spacing: 24) {
                    Text("Disabled").font(.title3.bold())
                    staticToggle(state: .off, isDisabled: true)
                    staticToggle(state: .togglingOn, isDisabled: true)
                    staticToggle(state: .on, isDisabled: true)
                    staticToggle(state: .togglingOff, isDisabled: true)
                }
            }
        }
        .padding(80)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private static func staticToggle(
        state: MEGAToggle.State,
        isDisabled: Bool
    ) -> some View {
        MEGAToggle(
            state: state,
            isDisabled: isDisabled,
            width: 96,
            toggleAction: { _ in }
        )
    }
}
