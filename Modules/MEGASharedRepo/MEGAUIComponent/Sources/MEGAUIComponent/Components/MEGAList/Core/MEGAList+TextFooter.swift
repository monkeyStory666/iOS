// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func footerText(_ text: String) -> UpdatedFooterView<MEGAListFooterView> {
        replaceFooterView {
            MEGAListFooterView(text: text)
        }
    }
}

public extension MEGAList where FooterView == MEGAListFooterView {
    func footerInset(_ isEnabled: Bool = true) -> Self {
        updatedFooterView {
            MEGAListFooterView(
                text: $0.text,
                inset: isEnabled ? TokenSpacing._5 : 0
            )
        }
    }
}

public struct MEGAListFooterView: View {
    public let text: String
    public var inset: CGFloat = 0

    public var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(TokenColors.Text.secondary.swiftUI)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, inset)
            .padding(.vertical, TokenSpacing._2)
    }
}

#Preview {
    struct MEGAListFooterPreview: View {
        @State var wordCount: Int = 8
        @State var footerInset = false

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .borderEdges(.vertical)
                        .footerText(String.loremIpsum(wordCount))
                        .footerInset(footerInset)
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
                    Toggle("Footer inset", isOn: $footerInset)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListFooterPreview()
}
