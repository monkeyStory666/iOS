// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

@MainActor
public extension ScrollViewProxy {
    /// Scrolls to a specified text field in a `ScrollView` after a delay to account for keyboard animation.
    ///
    /// - Parameter textFieldId: The identifier of the text field to scroll to.
    ///
    /// This method introduces a delay to wait for the keyboard's appearance animation before scrolling.
    /// It ensures the text field is centered in the visible area, avoiding being obscured by the keyboard.
    ///
    /// Use this method by assigning unique identifiers to text fields within a `ScrollView` and calling it when a `TextField` becomes focused.
    func textFieldKeyboardAvoidance(scrollTo textFieldId: String) {
        // We don't want this behavior in macOS because it looks very jumpy
        #if !targetEnvironment(macCatalyst)
        let keyboardAnimationDuration = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + keyboardAnimationDuration) {
            withAnimation(.spring(duration: 0.3)) {
                scrollTo(textFieldId, anchor: .center)
            }
        }
        #endif
    }
}
