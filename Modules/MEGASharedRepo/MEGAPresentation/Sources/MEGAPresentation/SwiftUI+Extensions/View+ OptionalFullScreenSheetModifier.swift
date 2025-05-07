// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

/// A ViewModifier that conditionally presents a full-screen cover or a sheet based on an optional value.
///
/// This ViewModifier extends SwiftUI's sheet and fullScreenCover functionality by allowing for the conditional
/// presentation of either a full-screen cover or a sheet. The choice between full-screen or sheet presentation
/// is based on the `isFullScreen` flag. It is particularly useful when you want the presentation style to adapt
/// based on the device or a specific condition while still depending on the presence of an optional value for the presentation trigger.
///
/// - Parameters:
///   - isFullScreen: A Boolean flag that determines whether the presentation should be a full-screen cover or a sheet.
///   - optionalValue: A binding to an optional value. The presentation is triggered when this value becomes non-nil.
///   - onDismiss: An optional closure executed when the presented view is dismissed.
///   - sheetContent: A closure returning the content of the presentation, taking a non-optional binding of the unwrapped value.
///
/// # Example:
/// ```swift
/// struct ExampleView: View {
///     @State private var optionalData: SomeDataType?
///
///     var body: some View {
///         // Some view content
///         .dynamicSheet(isFullScreen: true, unwrap: $optionalData) { dataBinding in
///             SheetOrFullScreenContentView(data: dataBinding)
///         }
///     }
/// }
/// ```
///
/// In this example, `SheetOrFullScreenContentView` is presented as either a full-screen cover or a sheet when `optionalData` becomes non-nil, based on the `isFullScreen` flag.
public struct OptionalFullScreenSheetViewModifier<Value: Identifiable, ContentView: View>: ViewModifier {
    var isFullScreen: Bool
    var optionalValue: Binding<Value?>
    var onDismiss: (() -> Void)?

    @ViewBuilder var sheetContent: (Binding<Value>) -> ContentView

    public init(
        isFullScreen: Bool,
        unwrap optionalValue: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        sheetContent: @escaping (Binding<Value>) -> ContentView
    ) {
        self.isFullScreen = isFullScreen
        self.optionalValue = optionalValue
        self.onDismiss = onDismiss
        self.sheetContent = sheetContent
    }

    public func body(content: Content) -> some View {
        if isFullScreen {
            content
                .fullScreenCover(
                    unwrap: optionalValue,
                    onDismiss: onDismiss,
                    content: sheetContent
                )
        } else {
            content
                .sheet(
                    item: optionalValue,
                    onDismiss: onDismiss
                ) { _ in
                    if let value = Binding(unwrap: optionalValue) {
                        sheetContent(value)
                    }
                }
        }
    }
}
