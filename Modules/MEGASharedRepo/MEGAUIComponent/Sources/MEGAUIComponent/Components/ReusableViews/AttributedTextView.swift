// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGADesignToken
import SwiftUI

public struct StringAttribute {
    fileprivate let id = UUID()
    fileprivate let text: String
    fileprivate let attributes: AttributeContainer
    fileprivate let action: (() -> Void)?

    public init(
        text: String,
        attributes: AttributeContainer,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        var attributes = attributes
        if action != nil {
            attributes.link = .init(string: "https://www.\(id).com")
        }
        self.attributes = attributes
        self.action = action
    }
    
    public init(
        text: String,
        font: Font,
        foregroundColor: Color = .primary,
        action: (() -> Void)? = nil
    ) {
        let attributes = AttributeContainer()
            .font(font)
            .foregroundColor(foregroundColor)
    
        self.init(text: text, attributes: attributes, action: action)
    }
}

public struct SubstringAttribute {
    fileprivate let id = UUID()
    fileprivate let text: String
    fileprivate let compareOptions: String.CompareOptions
    fileprivate let attributes: AttributeContainer
    fileprivate let action: (() -> Void)?

    public init(text: String,
                compareOptions: String.CompareOptions = [],
                attributes: AttributeContainer,
                action: (() -> Void)? = nil) {
        self.text = text
        self.compareOptions = compareOptions
        var attributes = attributes
        if action != nil {
            attributes.link = .init(string: "https://www.\(id).com")
        }
        self.attributes = attributes
        self.action = action
    }
    
    public init(
        text: String,
        font: Font,
        foregroundColor: Color = .primary,
        action: (() -> Void)? = nil
    ) {
        let attributes = AttributeContainer()
            .font(font)
            .foregroundColor(foregroundColor)
    
        self.init(text: text, attributes: attributes, action: action)
    }
}

public struct AttributedTextView: View {
    private let stringAttribute: StringAttribute
    private let substringAttributeList: [SubstringAttribute]
    private let truncationMode: Text.TruncationMode
    private let lineLimit: Int?
    private let textAlignment: TextAlignment
    
    public init(
        stringAttribute: StringAttribute,
        substringAttributeList: [SubstringAttribute],
        truncationMode: Text.TruncationMode = .tail,
        lineLimit: Int? = nil,
        textAlignment: TextAlignment = .leading
    ) {
        self.stringAttribute = stringAttribute
        self.substringAttributeList = substringAttributeList
        self.truncationMode = truncationMode
        self.lineLimit = lineLimit
        self.textAlignment = textAlignment
    }

    public var body: some View {
        Text(attributedString())
            .truncationMode(truncationMode)
            .lineLimit(lineLimit)
            .multilineTextAlignment(textAlignment)
            .environment(\.openURL, OpenURLAction { url in
                if url.absoluteString.contains("\(stringAttribute.id)") {
                    stringAttribute.action?()
                } else {
                    substringAttributeList.forEach { substringAttribute in
                        if url.absoluteString.contains("\(substringAttribute.id)") {
                            substringAttribute.action?()
                        }
                    }
                }
                return .discarded
            })
    }

    private func attributedString() -> AttributedString {
        var attributedString = AttributedString(stringAttribute.text)
        attributedString.mergeAttributes(stringAttribute.attributes)

        if stringAttribute.action != nil {
            attributedString.link = .init(string: "https://www.\(stringAttribute.id).com")
        }

        substringAttributeList.forEach { substringAttribute in
            if let range = attributedString.range(of: substringAttribute.text,
                                                  options: substringAttribute.compareOptions) {
                attributedString[range].mergeAttributes(substringAttribute.attributes)
            }
        }

        return attributedString
    }
}

struct AttributedTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            AttributedTextView(
                stringAttribute: .init(
                    text: "Don’t have MEGA account? Sign up",
                    font: .callout
                ),
                substringAttributeList: [
                    .init(
                        text: "Sign up",
                        attributes: AttributeContainer()
                            .font(.callout.weight(.semibold))
                            .foregroundColor(TokenColors.Link.primary.swiftUI)
                    )
                ]
            )

            AttributedTextView(
                stringAttribute: .init(
                    text: "I have read and understand MEGA’s Term of Service.",
                    font: .footnote
                ),
                substringAttributeList: [
                    .init(
                        text: "MEGA’s Term of Service",
                        attributes: AttributeContainer()
                            .font(.footnote)
                            .foregroundColor(TokenColors.Link.primary.swiftUI)
                    )
                ]
            )

            AttributedTextView(
                stringAttribute: .init(
                    // swiftlint:disable:next line_length
                    text: "We've sent an email to test@email.com with a link to complete your account setup. Tap the link to verify your email address and activate your account.\n\nIf you don't receive the email, check your spam folder or try again. For any other issues, please contact support@mega.nz",
                    font: .callout,
                    foregroundColor: TokenColors.Text.secondary.swiftUI
                ),
                substringAttributeList: [
                    .init(
                        text: "test@email.com",
                        attributes: AttributeContainer()
                            .font(.callout.weight(.bold))
                            .foregroundColor(TokenColors.Text.secondary.swiftUI)
                    ),
                    .init(
                        text: "support@mega.nz",
                        attributes: AttributeContainer()
                            .font(.callout)
                            .foregroundColor(TokenColors.Link.primary.swiftUI)
                    )
                ]
            )
        }
        .padding(.horizontal)
    }
}
