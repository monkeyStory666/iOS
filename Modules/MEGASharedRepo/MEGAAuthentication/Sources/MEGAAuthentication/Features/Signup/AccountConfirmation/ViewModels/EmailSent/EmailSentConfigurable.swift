// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import MEGAUIComponent
import MEGAPresentation
import SwiftUI

public protocol EmailSentConfigurable {
    var headerTitle: String { get }
    var primaryButtonTitle: String { get }
    var secondaryButtonTitle: String? { get }
    var descriptionTextWithEmail: DisplayTextWithEmail { get }
    var primaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? { get }
    var secondaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? { get }
    var showLoadingPublisher: AnyPublisher<Bool, Never>? { get }
    var descriptionTextWithEmailUpdatePublisher: AnyPublisher<DisplayTextWithEmail, Never>? { get }
}
