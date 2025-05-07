// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func headerText(_ text: String) -> UpdatedHeaderView<MEGAListHeaderView> {
        replaceHeaderView {
            MEGAListHeaderView(text: text)
        }
    }
}

public extension MEGAList where HeaderView == MEGAListHeaderView {
    func headerType(_ type: MEGAListHeaderType) -> Self {
        updatedHeaderView {
            MEGAListHeaderView(
                text: $0.text,
                font: $0.font,
                textColor: {
                    switch type {
                    case .primary: TokenColors.Text.primary.swiftUI
                    case .secondary: TokenColors.Text.secondary.swiftUI
                    }
                }(),
                inset: $0.inset
            )
        }
    }

    func headerState(_ state: MEGAListHeaderState) -> Self {
        updatedHeaderView {
            MEGAListHeaderView(
                text: $0.text,
                font: {
                    switch state {
                    case .default: return .footnote
                    case .bold: return .subheadline.bold()
                    }
                }(),
                textColor: $0.textColor,
                inset: $0.inset
            )
        }
    }

    func headerInset(_ isEnabled: Bool = true) -> Self {
        updatedHeaderView {
            MEGAListHeaderView(
                text: $0.text,
                font: $0.font,
                textColor: $0.textColor,
                inset: isEnabled ? TokenSpacing._5 : 0
            )
        }
    }
}

public enum MEGAListHeaderType {
    case primary
    case secondary
}

public enum MEGAListHeaderState {
    case `default`
    case bold
}

public struct MEGAListHeaderView: View {
    public let text: String

    public var font: Font = .footnote
    public var textColor: Color = TokenColors.Text.primary.swiftUI

    public var inset: CGFloat = 0

    public var body: some View {
        Text(text)
            .lineLimit(nil)
            .font(font)
            .foregroundStyle(textColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, TokenSpacing._2)
            .padding(.horizontal, inset)
    }
}

#Preview {
    struct MEGAListHeaderPreview: View {
        @State var wordCount: Int = 8
        @State var headerType: MEGAListHeaderType = .primary
        @State var headerState: MEGAListHeaderState = .default
        @State var headerInset = false

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .headerText(String.loremIpsum(wordCount))
                        .headerType(headerType)
                        .headerState(headerState)
                        .headerInset(headerInset)
                        .borderEdges(.vertical)
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                }

                Section("Configuration") {
                    Stepper("Word count: \(wordCount)", value: $wordCount, in: 1...100)
                    Picker("Header type", selection: $headerType) {
                        Text("Primary").tag(MEGAListHeaderType.primary)
                        Text("Secondary").tag(MEGAListHeaderType.secondary)
                    }
                    Picker("Header state", selection: $headerState) {
                        Text("Default").tag(MEGAListHeaderState.default)
                        Text("Bold").tag(MEGAListHeaderState.bold)
                    }
                    Toggle("Header inset", isOn: $headerInset)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListHeaderPreview()
}
