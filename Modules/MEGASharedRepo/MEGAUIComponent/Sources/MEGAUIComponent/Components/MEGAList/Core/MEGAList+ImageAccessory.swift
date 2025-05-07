// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func leadingImage(_ image: Image) -> UpdatedLeadingView<MEGAListImageAccessoryView> {
        replaceLeadingView {
            MEGAListImageAccessoryView(image: image)
        }
    }

    func trailingImage(_ image: Image) -> UpdatedTrailingView<MEGAListImageAccessoryView> {
        replaceTrailingView {
            MEGAListImageAccessoryView(image: image)
        }
    }
}

public extension MEGAList where LeadingView == MEGAListImageAccessoryView {
    func leadingImageHidden(_ isHidden: Bool) -> Self {
        updatedLeadingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                isHidden: isHidden,
                size: $0.size,
                color: $0.color
            )
        }
    }

    func leadingImageSize(_ size: CGSize) -> Self {
        updatedLeadingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                isHidden: $0.isHidden,
                size: size,
                color: $0.color
            )
        }
    }

    func leadingImageColor(_ color: Color) -> Self {
        updatedLeadingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                isHidden: $0.isHidden,
                size: $0.size,
                color: color
            )
        }
    }
}

public extension MEGAList where TrailingView == MEGAListImageAccessoryView {
    func trailingImageHidden(_ isHidden: Bool) -> Self {
        updatedTrailingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                isHidden: isHidden,
                size: $0.size,
                color: $0.color
            )
        }
    }

    func trailingImageSize(_ size: CGSize) -> Self {
        updatedTrailingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                size: size,
                color: $0.color
            )
        }
    }

    func trailingImageColor(_ color: Color) -> Self {
        updatedTrailingView {
            MEGAListImageAccessoryView(
                image: $0.image,
                size: $0.size,
                color: color
            )
        }
    }
}

// MARK: - SwiftUI View

public struct MEGAListImageAccessoryView: View {
    public var image: Image
    public var isHidden = false
    public var size: CGSize = .init(width: 40, height: 40)
    public var color: Color = TokenColors.Icon.primary.swiftUI

    public var body: some View {
        if isHidden {
            EmptyView()
        } else {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: size.width,
                    height: size.height,
                    alignment: .center
                )
                .foregroundStyle(color)
        }
    }
}

#Preview {
    struct MEGAListImageAccessoryPreview: View {
        @State var leadingImage = true
        @State var trailingImage = true

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .leadingImage(Image(systemName: "square.dashed.inset.filled"))
                        .leadingImageHidden(!leadingImage)
                        .trailingImage(Image(systemName: "square.dashed.inset.filled"))
                        .trailingImageHidden(!trailingImage)
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
                    Toggle("Leading image", isOn: $leadingImage)
                    Toggle("Trailing image", isOn: $trailingImage)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListImageAccessoryPreview()
}
