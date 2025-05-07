// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func leadingImage(icon: Image) -> UpdatedLeadingView<MEGAListImageAccessoryView> {
        replaceLeadingView {
            MEGAListImageAccessoryView(
                image: icon,
                size: .init(width: 24, height: 24),
                color: TokenColors.Icon.primary.swiftUI
            )
        }
    }

    func trailingImage(icon: Image) -> UpdatedTrailingView<MEGAListImageAccessoryView> {
        replaceTrailingView {
            MEGAListImageAccessoryView(
                image: icon,
                size: .init(width: 24, height: 24),
                color: TokenColors.Icon.primary.swiftUI
            )
        }
    }
}

#Preview {
    struct MEGAListImageAccessoryPreview: View {
        @State var leadingIcon = true
        @State var trailingIcon = true

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .leadingImage(icon: Image(systemName: "square.dashed"))
                        .leadingImageHidden(!leadingIcon)
                        .trailingImage(icon: Image(systemName: "square.dashed"))
                        .trailingImageHidden(!trailingIcon)
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
                    Toggle("Leading icon", isOn: $leadingIcon)
                    Toggle("Trailing icon", isOn: $trailingIcon)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListImageAccessoryPreview()
}
