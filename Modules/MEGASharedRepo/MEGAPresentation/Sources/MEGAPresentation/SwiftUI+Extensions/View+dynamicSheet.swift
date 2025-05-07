// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {
    /// Dynamically presents either a full-screen cover or a sheet based on an optional value.
    ///
    /// This function enhances SwiftUI's presentation functionality by allowing the dynamic choice between
    /// a full-screen cover or a sheet presentation, dependent on the `isFullScreen` flag and the presence
    /// of an optional value. It is particularly useful for adaptive UIs where the presentation style may need
    /// to change based on device capabilities or user preferences.
    ///
    /// - Parameters:
    ///   - isFullScreen: A Boolean flag to determine the presentation style. `true` for a full-screen cover, `false` for a sheet. Defaults to false but always true for Mac Catalyst environments.
    ///   - optionalValue: A binding to an optional value. The presentation is triggered when this value becomes non-nil.
    ///   - isMacCatalyst: A flag that indicates if the current OS is Mac Catalyst.
    ///   - onDismiss: An optional closure executed when the presentation is dismissed.
    ///   - content: A closure returning the content of the presentation, taking a non-optional binding of the unwrapped value.
    /// - Returns: A view that conditionally presents a full-screen cover or a sheet based on the existence of an optional value and the `isFullScreen` flag.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var optionalData: SomeDataType?
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .dynamicSheet(isFullScreen: false, unwrap: $optionalData) { dataBinding in
    ///             DynamicPresentationContentView(data: dataBinding)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `DynamicPresentationContentView` is presented as either a full-screen cover or a sheet when `optionalData` becomes non-nil, based on the `isFullScreen` flag and device capabilities.
    func dynamicSheet<Value: Identifiable, ContentView: View>(
        isFullScreen: Bool = false,
        unwrap optionalValue: Binding<Value?>,
        isMacCatalyst: Bool = Constants.isMacCatalyst,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> ContentView
    ) -> some View {
        modifier(
            OptionalFullScreenSheetViewModifier(
                isFullScreen: isFullScreen || isMacCatalyst,
                unwrap: optionalValue,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }

    /// Dynamically presents either a full-screen cover or a sheet based on a Boolean binding.
    ///
    /// This function enhances SwiftUI's presentation functionality by allowing the dynamic choice between
    /// a full-screen cover or a sheet presentation, dependent on the `isFullScreen` flag and the presence
    /// of a boolean binding. It is particularly useful for adaptive UIs where the presentation style may need
    /// to change based on device capabilities or user preferences.
    ///
    /// - Parameters:
    ///   - isFullScreen: A Boolean flag to determine the presentation style. `true` for a full-screen cover, `false` for a sheet. Defaults to false but always true for Mac Catalyst environments.
    ///   - isPresented: A binding to a boolean. The presentation is triggered when this value becomes true.
    ///   - isMacCatalyst: A flag that indicates if the current OS is Mac Catalyst.
    ///   - onDismiss: An optional closure executed when the presentation is dismissed.
    ///   - content: A closure returning the content of the presentation, taking a non-optional binding of the unwrapped value.
    /// - Returns: A view that conditionally presents a full-screen cover or a sheet based on the isPresented boolean value and the `isFullScreen` flag.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var isPresented = false
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .dynamicSheet(isFullScreen: false, isPresented: $isPresented) { boolValue in
    ///             DynamicPresentationContentView(boolValue: boolValue)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `DynamicPresentationContentView` is presented as either a full-screen cover or a sheet when isPresented becomes true, based on the `isFullScreen` flag and device capabilities.
    @ViewBuilder
    func dynamicSheet<ContentView: View>(
        isFullScreen: Bool = false,
        isPresented: Binding<Bool>,
        isMacCatalyst: Bool = Constants.isMacCatalyst,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Bool>) -> ContentView
    ) -> some View {
        if isFullScreen || isMacCatalyst {
            fullScreenCover(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        } else {
            sheet(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: { content(isPresented) }
            )
        }
    }
}
