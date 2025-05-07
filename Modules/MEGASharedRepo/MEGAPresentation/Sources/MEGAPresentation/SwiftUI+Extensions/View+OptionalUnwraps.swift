// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

public extension View {
    /// Presents a sheet when the optional value is non-nil.
    ///
    /// This function enhances SwiftUI's sheet functionality by allowing a sheet to be presented
    /// conditionally,
    /// based on the presence of an optional value. It is particularly useful when you want to
    /// display a sheet
    /// that depends on a specific piece of data being available.
    ///
    /// - Parameters:
    ///   - optionalValue: A binding to an optional value. The sheet is presented when this value
    ///                    becomes non-nil.
    ///   - onDismiss: An optional closure executed when the sheet is dismissed.
    ///   - content: A closure returning the content of the sheet, taking a non-optional binding of
    /// the unwrapped value.
    /// - Returns: A view that presents a sheet based on the existence of an optional value.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var optionalData: SomeDataType?
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .sheet(unwrap: $optionalData) { dataBinding in
    ///             SheetContentView(data: dataBinding)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `SheetContentView` is presented as a sheet when `optionalData` becomes
    /// non-nil.
    func sheet<Value>(
        unwrap optionalValue: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> some View
    ) -> some View where Value: Identifiable {
        sheet(item: optionalValue, onDismiss: onDismiss) { _ in
            if let value = Binding(unwrap: optionalValue) {
                content(value)
            }
        }
    }

    /// Presents an alert based on the presence of an optional value.
    ///
    /// This extension to the alert functionality in SwiftUI allows for presenting an alert
    /// conditionally, dependent on an optional data value. 
    /// This is useful when you need to show alerts in response to specific data conditions.
    ///
    /// - Parameters:
    ///   - title: A closure that takes the unwrapped value and returns the title for the alert.
    ///   - data: A binding to an optional value that triggers the alert presentation.
    ///   - actions: A closure that returns the actions for the alert, taking a non-optional binding
    ///              of the unwrapped value.
    ///   - message: A closure that returns the message for the alert, taking a non-optional binding
    ///              of the unwrapped value.
    /// - Returns: A view that presents an alert based on the existence of an optional value.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var alertData: SomeAlertDataType?
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .alert(
    ///             title: { data in Text("Alert Title") },
    ///             unwrap: $alertData,
    ///             actions: { dataBinding in Button("OK") { /* Handle action */ } },
    ///             message: { dataBinding in Text("Alert message") }
    ///         )
    ///     }
    /// }
    /// ```
    ///
    /// In this example, an alert with the specified title, message, and actions is presented when
    /// `alertData` is non-nil.
    func alert<T>(
        title: (T) -> Text,
        unwrap data: Binding<T?>,
        @ViewBuilder actions: @escaping (Binding<T>) -> some View,
        @ViewBuilder message: @escaping (Binding<T>) -> some View
    ) -> some View {
        alert(
            data.wrappedValue.map(title) ?? Text(""),
            isPresented: .init(
                get: { data.wrappedValue != nil },
                set: {
                    if !$0 {
                        DispatchQueue.main.async {
                            data.wrappedValue = nil
                        }
                    }
                }
            ),
            presenting: data.wrappedValue,
            actions: { _ in
                if let data = Binding(unwrap: data) {
                    actions(data)
                }
            },
            message: { _ in
                if let data = Binding(unwrap: data) {
                    message(data)
                }
            }
        )
    }
}

public extension View {
    /// Presents a full-screen cover based on the presence of an optional value.
    ///
    /// This method extends SwiftUI's `fullScreenCover` functionality, allowing for the presentation
    /// of a full-screen cover when an optional value is non-nil. It's useful in scenarios
    /// where the presentation should be conditional on specific data.
    ///
    /// - Parameters:
    ///   - optionalValue: A binding to an optional value. The full-screen cover is presented when
    ///                    this value becomes non-nil.
    ///   - onDismiss: An optional closure executed when the full-screen cover is dismissed.
    ///   - content: A closure returning the content of the full-screen cover, taking a non-optional
    ///              binding of the unwrapped value.
    /// - Returns: A view that presents a full-screen cover based on the existence of an optional
    ///            value.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var optionalCoverData: SomeCoverDataType?
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .fullScreenCover(unwrap: $optionalCoverData) { dataBinding in
    ///             FullScreenCoverContentView(data: dataBinding)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `FullScreenCoverContentView` is presented when `optionalCoverData` becomes
    /// non-nil.
    @available(iOS 15.0, *)
    func fullScreenCover<Value>(
        unwrap optionalValue: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> some View
    ) -> some View where Value: Identifiable {
        fullScreenCover(item: optionalValue, onDismiss: onDismiss) { _ in
            if let value = Binding(unwrap: optionalValue) {
                content(value)
            }
        }
    }

    /// Presents a full-screen cover when the `isPresented` state is true.
    ///
    /// This method extends SwiftUI's `fullScreenCover` functionality, allowing for the presentation of a full-screen
    /// cover based on a Boolean binding. This is particularly useful for scenarios where the presentation of a full-screen
    /// cover is controlled by a simple true/false state.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines when the full-screen cover is presented.
    ///   - onDismiss: An optional closure that is called when the full-screen cover is dismissed.
    ///   - content: A closure returning the content of the full-screen cover, taking a binding of the `isPresented` state.
    /// - Returns: A view that presents a full-screen cover based on the `isPresented` state.
    ///
    /// # Example:
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var isCoverPresented: Bool = false
    ///
    ///     var body: some View {
    ///         // Some view content
    ///         .fullScreenCover(isPresented: $isCoverPresented) { isPresentedBinding in
    ///             FullScreenCoverContentView(isPresented: isPresentedBinding)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// In this example, `FullScreenCoverContentView` is presented when `isCoverPresented` is set to true.
    @available(iOS 15.0, *)
    func fullScreenCover<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Bool>) -> Content
    ) -> some View where Content: View {
        fullScreenCover(isPresented: isPresented, onDismiss: onDismiss) {
            content(isPresented)
        }
    }
}
