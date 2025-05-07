// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {
    /// Modifies the tint color of alert buttons in SwiftUI views.
    ///
    /// Since SwiftUI doesn't directly support customizing the tint color of alert buttons, this modifier leverages underlying UIKit functionality to achieve the desired effect. 
    /// It changes the tint color for `UIAlertController` buttons when the view appears and resets it upon disappearance.
    ///
    /// Usage:
    /// Apply `.alertButtonTint(color:)` to a SwiftUI view to set the alert button tint color for any alerts presented from that view.
    ///
    /// Example:
    /// ```
    /// Button("Show Alert") {
    ///     // Present an alert
    /// }
    /// .alertButtonTint(color: .red) // Sets the alert button tint color to red
    /// ```
    ///
    /// - Warning: The change is applied globally to all `UIAlertController` instances and will revert once the view disappears.
    ///            This approach may affect alerts presented by other parts of the app simultaneously.
    /// - Parameter color: The `UIColor` to apply to alert buttons' tint color.
    func alertButtonTint(color: UIColor) -> some View {
        modifier(AlertButtonTintColor(color: color))
    }
}

struct AlertButtonTintColor: ViewModifier {
    let color: UIColor
    @State private var previousTintColor: UIColor?

    func body(content: Content) -> some View {
        content
            .onAppear {
                previousTintColor = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = color
            }
            .onDisappear {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = previousTintColor
            }
    }
}
