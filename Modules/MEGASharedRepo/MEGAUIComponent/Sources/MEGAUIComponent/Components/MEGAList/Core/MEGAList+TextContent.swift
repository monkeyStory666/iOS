// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGADesignToken
import SwiftUI

// MARK: - Convenience Initializer with Title and Subtitle

public extension MEGAList where
ContentView == MEGAListTextContentView,
LeadingView == EmptyView,
TrailingView == EmptyView,
HeaderView == EmptyView,
FooterView == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(contentView: {
            MEGAListTextContentView(
                title: title,
                subtitle: subtitle
            )
        })
    }
}

// MARK: - Component Configuration

public extension MEGAList where ContentView == MEGAListTextContentView {
    // MARK: - Text Font

    func titleFont(_ font: Font) -> Self {
        updatedContentView {
            $0.titleFont = font
            return $0
        }
    }

    func subtitleFont(_ font: Font) -> Self {
        updatedContentView {
            $0.subtitleFont = font
            return $0
        }
    }

    // MARK: - Text Colors

    func titleColor(_ color: Color) -> Self {
        updatedContentView {
            $0.titleColor = color
            return $0
        }
    }

    func subtitleColor(_ color: Color) -> Self {
        updatedContentView {
            $0.subtitleColor = color
            return $0
        }
    }

    // MARK: - Redaction / Shimmering

    func titleRedacted(length: Int = 8, isActive: Bool = false) -> Self {
        updatedContentView {
            $0.titleRedactionLength = isActive ? length : nil
            return $0
        }
    }

    func subtitleRedacted(length: Int = 8, isActive: Bool = false) -> Self {
        updatedContentView {
            $0.subtitleRedactionLength = isActive ? length : nil
            return $0
        }
    }

    // MARK: - Bold

    func boldTitle() -> Self {
        updatedContentView {
            $0.titleFont = $0.titleFont.bold()
            return $0
        }
    }

    func boldSubtitle() -> Self {
        updatedContentView {
            $0.subtitleFont = $0.subtitleFont.bold()
            return $0
        }
    }
    
    // MARK: - Line limits
    
    /// Sets the maximum number of lines that text can occupy in the title view.
    ///
    /// - Parameter number: The line limit. If `nil`, no line limit applies.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified title.
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///     .titleLineLimit(5)
    /// ```
    func titleLineLimit(_ number: Int?) -> Self {
        updatedContentView {
            $0.titleLineLimit = number
            return $0
        }
    }
    
    /// Sets the maximum number of lines that text can occupy in the subtitle view.
    ///
    /// - Parameter number: The line limit. If `nil`, no line limit applies.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified subtitle.
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///     .subtitleLineLimit(5)
    /// ```
    func subtitleLineLimit(_ number: Int?) -> Self {
        updatedContentView {
            $0.subtitleLineLimit = number
            return $0
        }
    }

    // MARK: - Substring Attribute

    /// Applies custom attributes to a specified substring of the title.
    ///
    /// Use this function to stylize a portion of the title text by applying a custom font, color, and/or an interaction action.
    /// If any custom attributes are not specified, the current attributes of the title will be used.
    ///
    /// - Parameters:
    ///   - text: The substring of the title that needs custom styling.
    ///   - font: The custom font to apply to the substring. If not provided, the title's current font is used.
    ///   - foregroundColor: The custom color to apply to the substring. If not provided, the title's current color is used.
    ///   - action: An optional closure to be executed when the substring is tapped.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified substring.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///     .titleSubstringAttribute("Tap here", font: .headline, foregroundColor: .blue, action: { print("Tapped!") })
    /// ```
    func titleSubstringAttribute(
        _ text: String,
        font: Font? = nil,
        foregroundColor: Color? = nil,
        action: (() -> Void)? = nil
    ) -> Self {
        var attributes = AttributeContainer()
        attributes.font = font
        attributes.foregroundColor = foregroundColor
        
        return titleSubstringAttribute(text, attributes: attributes, action: action)
    }
    
    /// Applies custom attributes to a specified substring of the title.
    ///
    /// Use this function to stylize a portion of the title text by applying a custom font, color, and/or an interaction action.
    /// If any custom attributes are not specified, the current attributes of the title will be used.
    ///
    /// - Parameters:
    ///   - text: The substring of the title that needs custom styling.
    ///   - compareOptions: The custom font to apply to the substring. If not provided, the title's current font is used.
    ///   - attributes: The custom attributes to apply to the substring. If font not provided, the title's current color is used. If custom foreground not provided, the title's current color is used.
    ///   - action: An optional closure to be executed when the substring is tapped.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified substring.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///    .titleSubstringAttribute(
    ///        "Tap here",
    ///        attributes: AttributeContainer()
    ///            .font(.body)
    ///            .foregroundColor(.blue),
    ///        action: { print("Tapped!") })
    /// ```
    func titleSubstringAttribute(
        _ text: String,
        compareOptions: String.CompareOptions = [],
        attributes: AttributeContainer,
        action: (() -> Void)? = nil
    ) -> Self {
        updatedContentView {
            var attributes = attributes
            if attributes.font == nil {
                attributes.font = $0.titleFont
            }
            if attributes.foregroundColor == nil {
                attributes.foregroundColor = $0.titleColor
            }
            
            let substringAttribute = SubstringAttribute(
                text: text,
                compareOptions: compareOptions,
                attributes: attributes,
                action: action
            )
            
            $0.titleSubstringAttribute = if let currentAttributes = $0.titleSubstringAttribute {
                currentAttributes + [substringAttribute]
            } else {
                [substringAttribute]
            }
            
            return $0
        }
    }

    /// Applies custom attributes to a specified substring of the subtitle.
    ///
    /// Use this function to stylize a portion of the subtitle text by applying a custom font, color, and/or an interaction action.
    /// If any custom attributes are not specified, the current attributes of the subtitle will be used.
    ///
    /// - Parameters:
    ///   - text: The substring of the subtitle that needs custom styling.
    ///   - font: The custom font to apply to the substring. If not provided, the subtitle's current font is used.
    ///   - foregroundColor: The custom color to apply to the substring. If not provided, the subtitle's current color is used.
    ///   - action: An optional closure to be executed when the substring is tapped.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified substring.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///    .subtitleSubstringAttribute(
    ///        "Tap here",
    ///        attributes: AttributeContainer()
    ///            .font(.body)
    ///            .foregroundColor(.red),
    ///        action: { print("Support tapped!") })
    /// ```
    func subtitleSubstringAttribute(
        _ text: String,
        font: Font? = nil,
        foregroundColor: Color? = nil,
        action: (() -> Void)? = nil
    ) -> Self {
        var attributes = AttributeContainer()
        attributes.font = font
        attributes.foregroundColor = foregroundColor
        
        return subtitleSubstringAttribute(text, attributes: attributes, action: action)
    }
    
    /// Applies custom attributes to a specified substring of the subtitle.
    ///
    /// Use this function to stylize a portion of the subtitle text by applying a custom font, color, and/or an interaction action.
    /// If any custom attributes are not specified, the current attributes of the subtitle will be used.
    ///
    /// - Parameters:
    ///   - text: The substring of the title that needs custom styling.
    ///   - compareOptions: The custom font to apply to the substring. If not provided, the subtitle's current font is used.
    ///   - attributes: The custom attributes to apply to the substring. If font not provided, the subtitle's current color is used. If custom foreground not provided, the title's current color is used.
    ///   - action: An optional closure to be executed when the substring is tapped.
    /// - Returns: A `Self` instance with the updated content view, reflecting the new attributes for the specified substring.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// MEGAList(title: "Tap here for more information")
    ///     .titleSubstringAttribute("Tap here", font: .headline, foregroundColor: .blue, action: { print("Tapped!") })
    /// ```
    func subtitleSubstringAttribute(
        _ text: String,
        compareOptions: String.CompareOptions = [],
        attributes: AttributeContainer,
        action: (() -> Void)? = nil
    ) -> Self {
        updatedContentView {
            var attributes = attributes
            if attributes.font == nil {
                attributes.font = $0.subtitleFont
            }
            if attributes.foregroundColor == nil {
                attributes.foregroundColor = $0.subtitleColor
            }
            
            let substringAttribute = SubstringAttribute(
                text: text,
                compareOptions: compareOptions,
                attributes: attributes,
                action: action
            )
            
            $0.subtitleSubstringAttribute = if let currentAttributes = $0.subtitleSubstringAttribute {
                currentAttributes + [substringAttribute]
            } else {
                [substringAttribute]
            }
            
            return $0
        }
    }

    // MARK: - Others

    func spacing(_ spacing: CGFloat) -> Self {
        updatedContentView {
            $0.spacing = spacing
            return $0
        }
    }
}

// MARK: - SwiftUI View

public struct MEGAListTextContentView: View {
    public let title: String
    public let subtitle: String?

    public var titleFont: Font = .body
    public var subtitleFont: Font = .footnote

    public var titleColor: Color = TokenColors.Text.primary.swiftUI
    public var subtitleColor: Color = TokenColors.Text.secondary.swiftUI

    public var titleLineLimit: Int?
    public var subtitleLineLimit: Int?
    
    public var titleRedactionLength: Int?
    public var subtitleRedactionLength: Int?

    public var titleSubstringAttribute: [SubstringAttribute]?
    public var subtitleSubstringAttribute: [SubstringAttribute]?

    public var spacing: CGFloat = 0

    public var body: some View {
        LazyVStack(spacing: spacing) {
            Group {
                AttributedTextView(
                    stringAttribute: .init(
                        text: titleText,
                        font: titleFont,
                        foregroundColor: titleColor
                    ),
                    substringAttributeList: titleSubstringAttribute ?? [],
                    lineLimit: titleLineLimit
                )
                .shimmering(active: titleIsRedacted)
                if let subtitleText {
                    AttributedTextView(
                        stringAttribute: .init(
                            text: subtitleText,
                            font: subtitleFont,
                            foregroundColor: subtitleColor
                        ),
                        substringAttributeList: subtitleSubstringAttribute ?? [],
                        lineLimit: subtitleLineLimit
                    )
                    .shimmering(active: subtitleIsRedacted)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 60)
    }

    private var titleIsRedacted: Bool {
        guard let titleRedactionLength = titleRedactionLength else {
            return false
        }

        return titleRedactionLength > 0
    }

    private var titleText: String {
        guard let titleRedactionLength, titleRedactionLength > 0 else {
            return title
        }

        return Array(repeating: "•", count: titleRedactionLength).joined()
    }

    private var subtitleIsRedacted: Bool {
        guard let subtitleRedactionLength = subtitleRedactionLength else {
            return false
        }

        return subtitleRedactionLength > 0
    }

    private var subtitleText: String? {
        guard let subtitleRedactionLength, subtitleRedactionLength > 0 else {
            return subtitle
        }

        return Array(repeating: "•", count: subtitleRedactionLength).joined()
    }
}

#Preview {
    struct MEGAListTextContentPreview: View {
        @State var titleLineLimit: Int = 0
        @State var subtitleLineLimit: Int = 0
        @State var titleWordCount: Int = 2
        @State var subtitleWordCount: Int = 10
        @State var titleFont: Font = .body
        @State var subtitleFont: Font = .footnote
        @State var titleColor: Color = TokenColors.Text.primary.swiftUI
        @State var subtitleColor: Color = TokenColors.Text.secondary.swiftUI
        @State var titleRedactionLength: Int = 12
        @State var subtitleRedactionLength: Int = 40
        @State var titleIsRedacted = false
        @State var subtitleIsRedacted = false
        @State var spacing: CGFloat = 0
        @State var isTitleSubstringEnabled = false
        @State var titleSubstring = ""
        @State var isSubtitleSubstringEnabled = false
        @State var subtitleSubstring = ""
        
        var body: some View {
            List {
                Section("Preview") {
                    MEGAList(
                        title: String.loremIpsum(titleWordCount),
                        subtitle: String.loremIpsum(subtitleWordCount)
                    )
                    .titleLineLimit(titleLineLimit != 0 ? titleLineLimit : nil)
                    .subtitleLineLimit(subtitleLineLimit != 0 ? subtitleLineLimit : nil)
                    .titleFont(titleFont)
                    .subtitleFont(subtitleFont)
                    .titleColor(titleColor)
                    .subtitleColor(subtitleColor)
                    .titleRedacted(
                        length: titleRedactionLength,
                        isActive: titleIsRedacted
                    )
                    .subtitleRedacted(
                        length: subtitleRedactionLength,
                        isActive: subtitleIsRedacted
                    )
                    .titleSubstringAttribute(
                        titleSubstring,
                        compareOptions: .caseInsensitive,
                        attributes: AttributeContainer().backgroundColor(.blue))
                    .subtitleSubstringAttribute(
                        subtitleSubstring,
                        compareOptions: .caseInsensitive,
                        attributes: AttributeContainer().foregroundColor(.red))
                    .spacing(spacing)
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
                    Stepper(
                        "Title word count: \(titleWordCount)",
                        value: $titleWordCount,
                        in: 1...100
                    )
                    Stepper(
                        "Subtitle word count: \(subtitleWordCount)",
                        value: $subtitleWordCount,
                        in: 1...100
                    )
                    Stepper(
                        "Title line limit: \(titleLineLimit)",
                        value: $titleLineLimit,
                        in: 0...5
                    )
                    Stepper(
                        "Subtitle line limit: \(subtitleLineLimit)",
                        value: $subtitleLineLimit,
                        in: 0...4
                    )
                    Stepper("Spacing: \(Int(spacing))", value: $spacing, in: 0...100)
                    Toggle("Title redacted", isOn: $titleIsRedacted)
                    Stepper(
                        "Title redaction length: \(titleRedactionLength)",
                        value: $titleRedactionLength,
                        in: 0...100
                    )
                    Toggle("Subtitle redacted", isOn: $subtitleIsRedacted)
                    Stepper(
                        "Subtitle redaction length: \(subtitleRedactionLength)",
                        value: $subtitleRedactionLength,
                        in: 0...100
                    )
                    Toggle("Title substring attributes", isOn: $isTitleSubstringEnabled)
                    if isTitleSubstringEnabled {
                        TextField("Enter Title Substring", text: $titleSubstring)
                    }
                    Toggle("Subtitle substring attributes", isOn: $isSubtitleSubstringEnabled)
                    if isSubtitleSubstringEnabled {
                        TextField("Enter Subtitle Substring", text: $subtitleSubstring)
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListTextContentPreview()
}
