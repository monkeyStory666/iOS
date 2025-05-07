// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGABanner: View {
    public var title: String?
    public var subtitle: AttributedString
    public var buttonText: String?

    public var state: MEGABannerState
    public var type: MEGABannerType

    public var buttonAction: (() -> Void)?
    public var closeButtonAction: (() -> Void)?

    public init(
        title: String? = nil,
        subtitle: String,
        buttonText: String? = nil,
        state: MEGABannerState,
        type: MEGABannerType = .inline,
        buttonAction: (() -> Void)? = nil,
        closeButtonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = AttributedString(subtitle)
        self.buttonText = buttonText
        self.state = state
        self.type = type
        self.buttonAction = buttonAction
        self.closeButtonAction = closeButtonAction
    }

    public init(
        title: String? = nil,
        subtitle: AttributedString,
        buttonText: String? = nil,
        state: MEGABannerState,
        type: MEGABannerType = .inline,
        buttonAction: (() -> Void)? = nil,
        closeButtonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonText = buttonText
        self.state = state
        self.type = type
        self.buttonAction = buttonAction
        self.closeButtonAction = closeButtonAction
    }

    public var body: some View {
        HStack(alignment: .top, spacing: TokenSpacing._5) {
            HStack(alignment: .top, spacing: TokenSpacing._3) {
                state.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(state.iconColor)
                VStack(alignment: .leading, spacing: TokenSpacing._3) {
                    if let title {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(TokenColors.Text.primary.swiftUI)
                    }
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(TokenColors.Text.primary.swiftUI)
                    if let buttonText {
                        Button(action: buttonAction ?? {}) {
                            Text(buttonText)
                                .font(.callout.bold())
                                .underline(color: buttonColor)
                                .foregroundStyle(buttonColor)
                        }
                        .disabled(buttonAction == nil)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let closeButtonAction {
                Button(action: closeButtonAction) {
                    XmarkCloseButton()
                }
            }
        }
        .padding(.horizontal, TokenSpacing._5)
        .padding(.vertical, TokenSpacing._7)
        .background(state.backgroundColor)
        .clipShape(
            RoundedRectangle(
                cornerRadius: type == .inline ? TokenSpacing._3 : 0
            )
        )
    }

    var buttonColor: Color {
        if buttonAction == nil {
            TokenColors.Button.disabled.swiftUI
        } else {
            TokenColors.Link.primary.swiftUI
        }
    }
}

public enum MEGABannerType {
    case inline
    case topAlert
}

public enum MEGABannerState {
    case info
    case success
    case warning
    case error

    var icon: Image {
        switch self {
        case .info:
            Image("InfoMediumThinOutline", bundle: .module)
        case .success:
            Image("CheckCircleMediumThinOutline", bundle: .module)
        case .warning:
            Image("AlertCircleMediumThinOutline", bundle: .module)
        case .error:
            Image("AlertTriangleMediumThinOutline", bundle: .module)
        }
    }

    var iconColor: Color {
        switch self {
        case .info:
            return TokenColors.Support.info.swiftUI
        case .success:
            return TokenColors.Support.success.swiftUI
        case .warning:
            return TokenColors.Support.warning.swiftUI
        case .error:
            return TokenColors.Support.error.swiftUI
        }
    }

    var backgroundColor: Color {
        switch self {
        case .info:
            return TokenColors.Notifications.notificationInfo.swiftUI
        case .success:
            return TokenColors.Notifications.notificationSuccess.swiftUI
        case .warning:
            return TokenColors.Notifications.notificationWarning.swiftUI
        case .error:
            return TokenColors.Notifications.notificationError.swiftUI
        }
    }
}

#Preview {
    struct MEGABannerPreview: View {
        @State var titleWordCount: Int = 3
        @State var subtitleWordCount: Int = 8
        @State var buttonTextWordCount: Int = 1
        @State var state: MEGABannerState = .info
        @State var type: MEGABannerType = .inline
        @State var hasButtonAction = true
        @State var hasCloseButtonAction = true

        var body: some View {
            List {
                Section("Preview") {
                    MEGABanner(
                        title: titleWordCount == 0
                            ? nil
                            : String.loremIpsum(titleWordCount),
                        subtitle: String.loremIpsum(subtitleWordCount),
                        buttonText: buttonTextWordCount == 0
                            ? nil
                            : String.loremIpsum(buttonTextWordCount),
                        state: state,
                        type: type,
                        buttonAction: hasButtonAction ? {} : nil,
                        closeButtonAction: hasCloseButtonAction ? {} : nil
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
                        in: 0...100
                    )
                    Stepper(
                        "Subtitle word count: \(subtitleWordCount)",
                        value: $subtitleWordCount,
                        in: 1...100
                    )
                    Stepper(
                        "Button text word count: \(buttonTextWordCount)",
                        value: $buttonTextWordCount,
                        in: 0...100
                    )
                    Picker("Style", selection: $state) {
                        Text("Info").tag(MEGABannerState.info)
                        Text("Success").tag(MEGABannerState.success)
                        Text("Warning").tag(MEGABannerState.warning)
                        Text("Error").tag(MEGABannerState.error)
                    }
                    Picker("Type", selection: $type) {
                        Text("Inline").tag(MEGABannerType.inline)
                        Text("Top Alert").tag(MEGABannerType.topAlert)
                    }
                    Toggle("Has button action", isOn: $hasButtonAction)
                    Toggle("Has close button action", isOn: $hasCloseButtonAction)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGABannerPreview()
}
