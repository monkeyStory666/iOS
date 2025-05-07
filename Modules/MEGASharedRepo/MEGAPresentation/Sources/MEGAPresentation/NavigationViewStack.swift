// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

/// A SwiftUI view wrapper that adapts to iOS version-specific navigation components.
///
/// This view simplifies navigation handling by using `NavigationStack` for iOS 16 and later,
/// and `NavigationView` for earlier iOS versions. It serves as a single interface for navigation,
/// abstracting the underlying iOS version differences.
///
/// - Parameters:
///   - ContentView: The type of the content view to be displayed within the navigation stack.
///
/// **Example Usage:**
/// ```swift
/// NavigationViewStack {
///     YourContentView()
/// }
/// ```
///
/// This approach ensures that your navigation structure remains consistent across different iOS versions.
public struct NavigationViewStack<ContentView: View>: View {
    public var content: () -> ContentView
    
    public init(content: @escaping () -> ContentView) {
        self.content = content
    }

    public var body: some View {
        if #available(iOS 16, *) {
            // swiftlint:disable:next discouraged_navigationstack_usage
            NavigationStack {
                content()
            }
        } else {
            // swiftlint:disable:next discouraged_navigationview_usage
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}

