// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import SwiftUI

public struct AlertModel: Equatable {
    public var title: String
    public var message: String
    public var buttons: [AlertButtonModel]

    public init(
        title: String,
        message: String = "",
        buttons: [AlertButtonModel] = []
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

public struct AlertButtonModel: Equatable {
    public let id = UUID()

    public var title: String
    public var role: ButtonRole?
    public var dismissAlert: Bool
    public var action: () -> Void
    public var asyncAction: (() async -> Void)?

    public init(
        _ title: String,
        role: ButtonRole? = nil,
        dismissAlert: Bool = true
    ) {
        self.title = title
        self.role = role
        self.dismissAlert = dismissAlert
        self.action = {}
        self.asyncAction = nil
    }

    public init(
        _ title: String,
        role: ButtonRole? = nil,
        dismissAlert: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.dismissAlert = dismissAlert
        self.action = action
        self.asyncAction = nil
    }

    public init(
        _ title: String,
        role: ButtonRole? = nil,
        dismissAlert: Bool = true,
        asyncAction: @escaping () async -> Void
    ) {
        self.title = title
        self.role = role
        self.dismissAlert = dismissAlert
        self.action = {}
        self.asyncAction = asyncAction
    }

    public static func == (lhs: AlertButtonModel, rhs: AlertButtonModel) -> Bool {
        lhs.title == rhs.title && lhs.role == rhs.role
    }
}

public extension View {
    /// Presents a customizable alert based on the presence of an `AlertModel` value.
    ///
    /// This extension enhances the alert functionality in SwiftUI, allowing for a more flexible and dynamic
    /// presentation of alerts based on a model. The `AlertModel` contains the title, message, and an array of
    /// `AlertButtonModel` items, each representing a button in the alert. This approach is useful for scenarios
    /// where the alert's content and the number of buttons are determined at runtime, such as in response to
    /// user actions or changes in application state.
    ///
    /// - Parameter alertModel: A binding to an optional `AlertModel` that triggers the alert presentation when
    ///                         non-nil. The model contains the title, message, and buttons for the alert.
    /// - Returns: A view that presents an alert based on the `AlertModel`.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @StateObject var viewModel = ExampleViewModel()
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .alert(unwrapModel: $viewModel.alertToPresent)
    ///     }
    /// }
    /// ```
    ///
    /// In this example, an alert with the specified title, message, and buttons in `alertToPresent` is shown when
    /// `alertToPresent` is non-nil. The `AlertModel` can be dynamically created and modified within the ViewModel,
    /// providing a flexible way to handle different alert scenarios.
    func alert(
        unwrapModel alertModel: Binding<AlertModel?>
    ) -> some View {
        alert(
            title: { Text($0.title) },
            unwrap: alertModel,
            actions: { alert in
                ForEach(alert.buttons, id: \.id) { button in
                    DismissAlertButton(alertModel: alertModel, button: button.wrappedValue)
                }
            },
            message: { alert in
                if !alert.message.wrappedValue.isEmpty {
                    Text(alert.message.wrappedValue)
                }
            }
        )
    }
}

struct DismissAlertButton: View {
    @Binding var alertModel: AlertModel?

    let button: AlertButtonModel

    var body: some View {
        Button(
            button.title,
            role: button.role,
            action: {
                if button.dismissAlert {
                    alertModel = nil
                }

                if let asyncAction = button.asyncAction {
                    Task { await asyncAction() }
                } else {
                    button.action()
                }
            }
        )
    }
}
