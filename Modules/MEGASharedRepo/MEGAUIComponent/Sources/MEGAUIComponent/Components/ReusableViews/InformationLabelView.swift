// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct InformationLabelView: View {
    public let title: String
    public let subtitle: String
    public let image: Image?
    public let imageSize: CGSize?
    public let shouldFixHorizontalSize: Bool
    public var alignment: Alignment
    public var textAlignment: TextAlignment

    public init(
        title: String,
        subtitle: String,
        image: Image?,
        imageSize: CGSize? = .init(width: 80, height: 80),
        shouldFixHorizontalSize: Bool = true,
        alignment: Alignment = .leading,
        textAlignment: TextAlignment = .leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageSize = imageSize
        self.shouldFixHorizontalSize = shouldFixHorizontalSize
        self.alignment = alignment
        self.textAlignment = textAlignment
    }

    public var body: some View {
        VStack(alignment: alignment.horizontal, spacing: TokenSpacing._7) {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize?.width, height: imageSize?.height)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            VStack(alignment: alignment.horizontal, spacing: TokenSpacing._5) {
                Text(.init(title))
                    .font(.title.bold())
                    .foregroundColor(TokenColors.Text.primary.swiftUI)
                Text(.init(subtitle))
                    .font(.callout)
                    .foregroundColor(TokenColors.Text.secondary.swiftUI)
            }
        }
        .multilineTextAlignment(textAlignment)
        .fixedSize(horizontal: false, vertical: shouldFixHorizontalSize)
        .frame(maxWidth: .infinity, alignment: alignment)
    }
}

struct InformationLabelView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InformationLabelView(
                title: "Information Title",
                subtitle: Array(repeating: "Information label view subtitle, ", count: 3).joined(),
                image: Image(systemName: "checkmark")
            )
            .padding(TokenSpacing._7)
            InformationLabelView(
                title: "Information Title",
                subtitle: Array(repeating: "Information label view subtitle, ", count: 3).joined(),
                image: Image(systemName: "checkmark"),
                alignment: .center,
                textAlignment: .center
            )
            .padding(TokenSpacing._7)
        }
    }
}
