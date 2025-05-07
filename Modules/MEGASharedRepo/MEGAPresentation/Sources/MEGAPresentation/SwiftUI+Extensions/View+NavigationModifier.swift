// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

/// A view modifier that helps with SwiftUI navigation by wrapping the content in a `NavigationLink`.
///
/// This view modifier allows for declarative, conditional navigation in SwiftUI by using a bound Boolean property,
/// a destination view, and an optional dismiss action. In iOS 16 and later, it uses the `navigationDestination`
/// API for navigation handling, while in earlier versions, it uses `NavigationLink`.
///
/// - Warning: This modifier is designed to be used with `NavigationViewStack` to ensure proper navigation behavior
///   across different iOS versions. Using it directly with `NavigationView` or `NavigationStack` may lead to
///   broken navigation in certain iOS versions.
///
/// - SeeAlso: `View.navigationLink(isActive:destination:)`
public struct NavigationModifier<Destination: View>: ViewModifier {
    @Binding public var isActive: Bool

    public let destination: () -> Destination
    public let onDismiss: (() -> Void)?

    public init(
        isActive: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self._isActive = isActive
        self.onDismiss = onDismiss
        self.destination = destination
    }

    public func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content
                .navigationDestination(isPresented: $isActive, destination: destination)
                .onChange(of: isActive) { newValue in
                    if !isActive { onDismiss?() }
                }
        } else {
            ZStack {
                NavigationLink(
                    isActive: $isActive,
                    destination: destination,
                    label: { EmptyView() }
                )
                content
            }
            .onChange(of: isActive) { newValue in
                if !isActive { onDismiss?() }
            }
        }
    }
}

public extension View {
    /// Adds a `NavigationLink` to the view that will navigate to the given `Destination` when `isActive` becomes `true`.
    ///
    /// Use this modifier for easy, conditional navigation in your SwiftUI apps. In iOS 16 and later, it utilizes
    /// the `navigationDestination` API for a more integrated navigation experience, while in earlier versions,
    /// it relies on `NavigationLink`.
    ///
    /// - Warning: Ensure to use this within a `NavigationViewStack` for consistent navigation behavior across
    ///   different iOS versions. Direct usage with `NavigationView` or `NavigationStack` may not work as expected
    ///   on certain iOS versions.
    ///
    /// - Parameters:
    ///   - isActive: A binding to a boolean that will trigger the navigation when set to `true`.
    ///   - onDismiss: An optional closure that gets called when the navigation is dismissed.
    ///   - destination: A closure that returns the destination view.
    /// - Returns: A new view that will navigate to the given destination when the condition becomes `true`.
    ///
    /// # Example:
    /// ```swift
    /// var testButton: some View {
    ///     Button("Navigate") {
    ///         // do something
    ///     }
    ///     .navigationLink(
    ///         isActive: $shouldNavigate,
    ///         onDismiss: { // handle dismiss },
    ///         destination: {
    ///             DestinationView()
    ///         }
    ///     )
    /// }
    /// ```
    func navigationLink<Destination: View>(
        isActive: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        modifier(
            NavigationModifier(
                isActive: isActive,
                onDismiss: onDismiss,
                destination: destination
            )
        )
    }

    /// Adds a `NavigationLink` to the view that navigates based on the presence of an optional value.
    ///
    /// This variant of the `navigationLink` modifier allows for navigation to be triggered when an optional value
    /// becomes non-nil. In iOS 16 and later, this navigation is handled using the `navigationDestination` API,
    /// while in earlier iOS versions, it uses `NavigationLink`. This method is particularly useful in scenarios
    /// where navigation is contingent upon a specific value being present.
    ///
    /// - Warning: Ensure to use this within a `NavigationViewStack` for consistent navigation behavior across
    ///   different iOS versions. Direct usage with `NavigationView` or `NavigationStack` may not work as expected
    ///   on certain iOS versions.
    ///
    /// - Parameters:
    ///   - unwrap: A binding to an optional value. Navigation is triggered when this value becomes non-nil.
    ///   - onDismiss: An optional closure that gets called when the navigation is dismissed.
    ///   - destination: A closure that takes a non-optional binding of the unwrapped value and returns the destination view.
    /// - Returns: A new view that navigates to the given destination when the optional value becomes non-nil.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var optionalValue: SomeViewModel?
    ///
    ///     var body: some View {
    ///         VStack {
    ///             // Other views
    ///         }
    ///         .navigationLink(
    ///             unwrap: $optionalValue,
    ///             onDismiss: { // handle dismiss },
    ///             destination: { valueBinding in
    ///                 DestinationView(viewModel: valueBinding)
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `DestinationView` is presented when `optionalValue` becomes non-nil.
    func navigationLink<Destination: View, Value>(
        unwrap optionalValue: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping (Binding<Value>) -> Destination
    ) -> some View {
        modifier(
            NavigationModifier(
                isActive: .init(
                    get: { optionalValue.wrappedValue != nil },
                    set: {
                        if !$0 {
                            DispatchQueue.main.async {
                                optionalValue.wrappedValue = nil
                            }
                        }
                    }
                ),
                onDismiss: onDismiss,
                destination: {
                    if let value = Binding(unwrap: optionalValue) {
                        destination(value)
                    }
                }
            )
        )
    }
}
