// Copyright © 2025 MEGA Limited. All rights reserved.

public struct CancelSurveyOption: Equatable {
    /// This is the text that will be sent to the API
    public let text: String

    /// This is the text that will be displayed to the user.
    /// This text should be localized.
    public let displayText: String

    /// Creates a new instance of `CancelSurveyOption`.
    /// - Parameters:
    ///  - text: This is the text that will be sent to the API
    ///  - displayText: This is the text that will be displayed to the user.
    public init(
        text: String,
        displayText: String
    ) {
        self.text = text
        self.displayText = displayText
    }
}
