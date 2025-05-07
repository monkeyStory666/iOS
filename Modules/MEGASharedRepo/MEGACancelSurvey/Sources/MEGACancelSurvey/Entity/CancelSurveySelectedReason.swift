// Copyright © 2025 MEGA Limited. All rights reserved.

public struct CancelSurveySelectedReason: Equatable, Sendable {
    public let text: String
    public let position: Int

    public init(text: String, position: Int) {
        self.text = text
        self.position = position
    }
}
