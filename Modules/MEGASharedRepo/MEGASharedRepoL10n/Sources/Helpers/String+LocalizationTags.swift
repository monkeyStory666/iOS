// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public extension String {
    /// Replaces localization tags in the string with provided URLs in markdown link format.
    /// You can assign this for specific tag, (default is `L`). So for strings with multiple tags
    /// you can assign the first link using the `L1` tag, and the second one as `L2` tag.
    ///
    /// - Parameter link: URL link to assign
    /// - Parameter tag: The tag to assign the link to. Default is `L`.
    /// - Returns: A new string with the localization tags replaced.
    ///
    /// Example usage:
    /// ```swift
    /// print(
    ///     "Check this [L]link[/L]"
    ///         .assignLink(URL(string: "https://example.com")!, forTag: "L")
    /// )
    /// // Outputs: "Check this [link](https://example.com)"
    ///
    /// print(
    ///     "Check this [L1]first link[/L1] and [L2]second link[/L2]"
    ///         .assignLink(URL(string: "https://firstlink.com")!, forTag: "L1")
    ///         .assignLink(URL(string: "https://secondlink.com")!, forTag: "L2")
    /// )
    /// // Outputs: "Check this [first link](https://firstlink.com) and [second link](https://secondlink"
    /// ```
    func assignLink(_ link: URL, forTag tag: String = "L") -> String {
        assignLink(link.absoluteString, forTag: tag)
    }
    
    /// Replaces localization tags in the string with provided url strings in markdown link format.
    /// You can assign this for specific tag, (default is `L`). So for strings with multiple tags
    /// you can assign the first link using the `L1` tag, and the second one as `L2` tag.
    ///
    /// - Parameter link: URL string link to assign to the tagged substring
    /// - Parameter tag: The tag to assign the link to. Default is `L`.
    /// - Returns: A new string with the localization tags replaced.
    ///
    /// Example usage:
    /// ```swift
    /// print(
    ///     "Check this [L]link[/L]"
    ///         .assignLink("https://example.com", forTag: "L")
    /// )
    /// // Outputs: "Check this [link](https://example.com)"
    ///
    /// print(
    ///     "Check this [L1]first link[/L1] and [L2]second link[/L2]"
    ///         .assignLink("https://firstlink.com", forTag: "L1")
    ///         .assignLink("https://secondlink.com", forTag: "L2")
    /// )
    /// // Outputs: "Check this [first link](https://firstlink.com) and [second link](https://secondlink"
    /// ```
    func assignLink(_ link: String, forTag tag: String = "L") -> String {
        let matchedString = getLocalizationSubstring(tag: tag)
        guard !matchedString.isEmpty else { return self }
        return replacingOccurrences(
            of: "[\(tag)]\(matchedString)[/\(tag)]",
            with: "[\(matchedString)](\(link))"
        ).assignLink(link, forTag: tag)
    }
    
    /// Removes all localization tags (e.g., `[A]...[/A]`, `[B]...[/B]`) from the string including nested tags, leaving the text inside them.
    /// - Returns: A new string with all localization tags removed.
    ///
    /// Example usage:
    /// ```
    /// let exampleString = "This is a [A]test[/A] [L1]Link One[/L1] [A][B]nested[/B][/A]"
    /// print(exampleString.removeAllLocalizationTags())
    /// // Outputs: "This is a test Link One nested"
    /// ```
    func removeAllLocalizationTags() -> String {
        guard let regex = try? NSRegularExpression(pattern: bracketRegexPattern, options: []) else { return self }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        var modifiedString = self
        
        for match in matches.reversed() {
            guard let range = Range(match.range, in: self) else { continue }
            modifiedString = modifiedString.replacingOccurrences(of: String(self[range]), with: "")
        }
        
        return modifiedString
    }
    
    /// Retrieves the substring enclosed within a certain localization tag, where tags are in the format `[X]...[/X]`.
    /// If the specified tag index does not exist, returns an empty string.
    /// - Parameter tag: The string value of the tag.
    /// - Parameter removeNestedTags: A boolean value indicating whether to remove nested tags.
    /// - Returns: The substring inside the tag or an empty string if it is not a valid tag.
    ///
    /// Example usage:
    /// ```
    /// let exampleString = "First [A]Alpha[/A], Second [B]Beta[/B]"
    /// print(exampleString.getLocalizationSubstring(tag: "A"))
    /// // Outputs: "Alpha"
    /// ```
    func getLocalizationSubstring(
        tag: String,
        removeNestedTags: Bool = true
    ) -> String {
        guard let result = substring(from: "[\(tag)]", to: "[/\(tag)]") else { return "" }
        return removeNestedTags ? result.removeAllLocalizationTags() : result
    }

    // swiftlint:disable:next identifier_name
    private func substring(from: String, to: String) -> String? {
        guard let fromRange = range(of: from)?.upperBound,
              let toRange = self[fromRange...].range(of: to)?.lowerBound
        else {
            return nil
        }
        
        return String(self[fromRange ..< toRange])
    }
    
    private var bracketRegexPattern: String { "\\[(.*?)\\]" }
}

