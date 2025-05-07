// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGAPrompt: View {
    public var title: String
    public var type: MEGAPromptType

    public init(
        title: String,
        type: MEGAPromptType
    ) {
        self.title = title
        self.type = type
    }

    public var body: some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(TokenColors.Text.primary.swiftUI)
            .multilineTextAlignment(.center)
            .padding(TokenSpacing._5)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(type.backgroundColor)
    }
}

public enum MEGAPromptType {
    case transparent
    case info
    case success
    case warning
    case error

    var backgroundColor: Color {
        switch self {
        case .transparent:
            return .clear
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
    struct MEGAPromptPreview: View {
        @State var titleWordCount: Int = 5
        @State var type: MEGAPromptType = .success

        var body: some View {
            List {
                Section("Preview") {
                    MEGAPrompt(
                        title: String.loremIpsum(titleWordCount),
                        type: type
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
                    Picker("Type", selection: $type) {
                        Text("Transparent")
                            .tag(MEGAPromptType.transparent)
                        Text("Info")
                            .tag(MEGAPromptType.info)
                        Text("Success")
                            .tag(MEGAPromptType.success)
                        Text("Warning")
                            .tag(MEGAPromptType.warning)
                        Text("Error")
                            .tag(MEGAPromptType.error)
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAPromptPreview()
}
