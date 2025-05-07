// Copyright © 2024 MEGA Limited. All rights reserved.

import UIKit
import SwiftUI

/// A struct for presenting bottom sheet interfaces in SwiftUI.
/// Note: This struct utilizes UIKit's UISheetPresentationController and is designed for iOS 15 and later.
@MainActor public struct MEGABottomSheet {

    /// Wraps the UIKit's detents (UISheetPresentationController.Detent)
    public enum Detent: Identifiable, CustomStringConvertible, Equatable {
        case medium
        case large
        case fixed(Int)
        case ratio(Double)
        
        public var id: String { description }
        
        public var description: String {
            switch self {
            case .medium:
                return "Medium"
                
            case .large:
                return "Large"
                
            case .fixed(let value):
                return "Fixed height of \(value)"
                
            case .ratio(let value):
                return "Ratio of \(value)"
            }
        }
        
        /// Converts `Detent` to `UISheetPresentationController.Detent`.
        @MainActor var asUIKitDetent: UISheetPresentationController.Detent? {
            switch self {
            case .medium:
                return .medium()
                
            case .large:
                return .large()
                
            case .fixed(let value):
                guard #available(iOS 16, *) else { return .medium() }
                return .custom { _ in CGFloat(value) }
                
            case .ratio(let value):
                guard #available(iOS 16, *) else { return .medium() }
                return .custom { $0.maximumDetentValue * value }
            }
        }
        
        @available(iOS 16.0, *)
        var swiftUIDetent: PresentationDetent {
            switch self {
            case .medium:
                return .medium
            case .large:
                return .large
            case .fixed(let height):
                return .height(CGFloat(height))
            case .ratio(let ratio):
                return .fraction(ratio)
            }
        }
    }
    
    /// Wraps the UIKit's largestUndimmedDetentIdentifier.
    /// *"The largest detent that doesn’t dim the view underneath the sheet."*
    public enum LargestUndimmedDetent: CaseIterable, Identifiable {
        case medium
        case large
        
        fileprivate var value: UISheetPresentationController.Detent.Identifier {
            switch self {
            case .medium:
                return .medium
                
            case .large:
                return .large
            }
        }
        
        public var description: String {
            switch self {
            case .medium:
                return "Medium"
                
            case .large:
                return "Large"
            }
        }
        
        public var id: Int {
            self.hashValue
        }
    }
    
    /// Reference to the presenting UINavigationController.
    private static var ref: UINavigationController? = nil
    
    /// Dismisses the currently presented bottom sheet.
    public static func dismiss() {
        ref?.dismiss(animated: true, completion: { ref = nil })
    }
    
    /// Determines the user interface style based on the color scheme.
    /// - Parameter colorScheme: The color scheme.
    ///  - Returns: The corresponding `UIUserInterfaceStyle`.
    private static func userInterfaceStyle(for colorScheme: ColorScheme) -> UIUserInterfaceStyle? {
        switch colorScheme {
        case .dark:
            return .dark
            
        case .light:
            return .light
            
        @unknown default:
            return nil
        }
    }

    /// Presents a bottom sheet with the specified configurations.
    ///
    /// - Parameters:
    ///   - detents: An array of `Detent` representing the possible sizes or ratios for the bottom sheet.
    ///   - shouldScrollExpandSheet: A boolean indicating whether the sheet should expand when scrolled to the edge.
    ///   - largestUndimmedDetent: An optional `LargestUndimmedDetent` representing the largest undimmed detent.
    ///   - showDragIndicator: A boolean indicating whether the grabber should be visible.
    ///   - cornerRadius: An optional `CGFloat` value representing the corner radius of the sheet.
    ///   - showsInCompactHeight: A boolean indicating whether the sheet should be attached to the edge in compact height.
    ///   - showNavigationBar: A boolean indicating whether the navigation bar should be visible.
    ///   - dismissable: A boolean indicating whether the sheet is dismissible.
    ///   - preferredColorScheme: An optional `ColorScheme` representing the preferred color scheme.
    ///   - contentView: A closure returning the content view of the bottom sheet.
    
    fileprivate static func present<Content: View>(
        detents: [Detent],
        shouldScrollExpandSheet: Bool,
        largestUndimmedDetent: LargestUndimmedDetent?,
        showDragIndicator: Bool,
        cornerRadius: CGFloat?,
        showsInCompactHeight: Bool,
        showNavigationBar: Bool,
        dismissable: Bool,
        preferredColorScheme: ColorScheme?,
        @ViewBuilder _ contentView: @escaping () -> Content
    ) {
        let detailViewController = UIHostingController(rootView: contentView())
        let nav = UINavigationController(rootViewController: detailViewController)
        
        ref = nav
        
        nav.navigationBar.isHidden = !showNavigationBar
        nav.modalPresentationStyle = .pageSheet
        nav.isModalInPresentation = !dismissable
        
        if let preferredColorScheme, let style = userInterfaceStyle(for: preferredColorScheme) {
            nav.overrideUserInterfaceStyle = style
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = detents.isEmpty ? [.medium()] : detents.compactMap { $0.asUIKitDetent }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = shouldScrollExpandSheet
            setLargestUndimmedDetentIdentifier(
                to: sheet,
                detent: largestUndimmedDetent,
                availableDetents: detents
            )
            sheet.prefersGrabberVisible = showDragIndicator
            sheet.preferredCornerRadius = cornerRadius
            sheet.prefersEdgeAttachedInCompactHeight = showsInCompactHeight
            
            if let firstDetent = detents.first {
                switch firstDetent {
                case .medium:
                    sheet.selectedDetentIdentifier = .medium
                    
                case .large:
                    sheet.selectedDetentIdentifier = .large
                    
                case .ratio, .fixed:
                    guard #available(iOS 16, *) else {
                        if detents.contains(.medium) {
                            sheet.selectedDetentIdentifier = .medium
                        } else if detents.contains(.large) {
                            sheet.selectedDetentIdentifier = .large
                        }
                        break
                    }
                    sheet.selectedDetentIdentifier = firstDetent.asUIKitDetent?.identifier
                }
            }
        }
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene}
                .first?.windows
                .filter { $0.isKeyWindow }.first
        
        keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
    }
    
    /// Sets the largest undimmed detent identifier to the specified sheet based on the available detents.
    ///
    /// - Parameters:
    ///   - sheet: The `UISheetPresentationController`.
    ///   - detent: The `LargestUndimmedDetent`.
    ///   - availableDetents: The array of available `Detent`.

    fileprivate static func setLargestUndimmedDetentIdentifier(
        to sheet: UISheetPresentationController,
        detent: LargestUndimmedDetent?,
        availableDetents: [Detent]
    ) {
        guard let detent = detent else { return }
        if detent == .medium || detent == .large {
            sheet.largestUndimmedDetentIdentifier = detent.value
        } else {
            if availableDetents.contains(.medium) {
                sheet.largestUndimmedDetentIdentifier = .medium
            } else if availableDetents.contains(.large) {
                sheet.largestUndimmedDetentIdentifier = .large
            }
        }
    }
}

public extension View {
    /// Presents a bottomSheet when a binding to a Boolean value that you provide is true.
   @ViewBuilder func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: [MEGABottomSheet.Detent] = [.medium],
        shouldScrollExpandSheet: Bool = true,
        largestUndimmedDetent: MEGABottomSheet.LargestUndimmedDetent? = nil,
        showDragIndicator: Bool = false,
        cornerRadius: CGFloat? = nil,
        showsInCompactHeight: Bool = false,
        showNavigationBar: Bool = true,
        dismissable: Bool = true,
        preferredColorScheme: ColorScheme? = nil,
        useCustomSheet: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        if #available(iOS 16.4, *), !useCustomSheet {
            sheet(
                isPresented: isPresented,
                content: {
                    content()
                        .presentationDetents(Set(detents.map { $0.swiftUIDetent }))
                        .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                        .presentationCornerRadius(cornerRadius)
                }
            )
        } else {
            background {
                Color.clear
                    .onDisappear {
                        MEGABottomSheet.dismiss()
                    }
                    .onChange(of: isPresented.wrappedValue) { show in
                        if show {
                            MEGABottomSheet.present(
                                detents: detents,
                                shouldScrollExpandSheet: shouldScrollExpandSheet,
                                largestUndimmedDetent: largestUndimmedDetent,
                                showDragIndicator: showDragIndicator,
                                cornerRadius: cornerRadius,
                                showsInCompactHeight: showsInCompactHeight,
                                showNavigationBar: showNavigationBar,
                                dismissable: dismissable,
                                preferredColorScheme: preferredColorScheme
                            ) {
                                content()
                                    .onDisappear {
                                        isPresented.projectedValue.wrappedValue = false
                                    }
                            }
                        } else {
                            MEGABottomSheet.dismiss()
                        }
                    }
            }
        }
    }

    /**
     Presents a bottom sheet when an optional value is non-nil.

     This view modifier conditionally presents a bottom sheet based on the state of an optional value. When the bound optional value is non-nil, the provided content is displayed within a sheet. On iOS 16.4 and later (unless `useCustomSheet` is set to true), the native `.sheet` modifier is used. Otherwise, a custom implementation via `MEGABottomSheet` is employed to present the bottom sheet.

     - Parameters:
       - unwrap optionalValue: A binding to an optional value. The bottom sheet is presented when this value is non-nil.
       - detents: An array of detents defining the possible heights and behaviors for the sheet. Defaults to `[.medium]`.
       - shouldScrollExpandSheet: A Boolean that determines whether scrolling within the sheet should expand it. Defaults to `true`.
       - largestUndimmedDetent: The largest detent that remains undimmed while the sheet is presented. Defaults to `nil`.
       - showDragIndicator: A Boolean that indicates whether a drag indicator should be shown. Defaults to `false`.
       - cornerRadius: An optional corner radius for the sheet’s presentation. Defaults to `nil`.
       - showsInCompactHeight: A Boolean that indicates whether the sheet should be shown in compact height environments. Defaults to `false`.
       - showNavigationBar: A Boolean that indicates whether a navigation bar is displayed within the sheet. Defaults to `true`.
       - dismissable: A Boolean that indicates whether the sheet can be dismissed interactively. Defaults to `true`.
       - preferredColorScheme: An optional color scheme that the sheet should prefer. Defaults to `nil`.
       - useCustomSheet: A Boolean that forces the use of the custom sheet implementation even on iOS 16.4 and later. Defaults to `false`.
       - onDismiss: An optional closure that is executed when the sheet is dismissed.
       - content: A view builder closure that produces the content for the sheet. It receives a binding to the unwrapped value.

     - Returns: A view that conditionally presents a bottom sheet based on the provided binding.

     - Example:
        ```swift
        .bottomSheet(
            unwrap: $viewModel.route.case(
                /SettingsListUnlockMethodRowViewModel.Route.disablePINCode
            ),
            detents: [.fixed(350)],
            showDragIndicator: true,
            cornerRadius: TokenRadius.large
        ) { $viewModel in
            DisablePINCodeView(viewModel: $viewModel.wrappedValue)
        }
        ```
    */
    @ViewBuilder func bottomSheet<Content: View, Value>(
        unwrap optionalValue: Binding<Value?>,
        detents: [MEGABottomSheet.Detent] = [.medium],
        shouldScrollExpandSheet: Bool = true,
        largestUndimmedDetent: MEGABottomSheet.LargestUndimmedDetent? = nil,
        showDragIndicator: Bool = false,
        cornerRadius: CGFloat? = nil,
        showsInCompactHeight: Bool = false,
        showNavigationBar: Bool = true,
        dismissable: Bool = true,
        preferredColorScheme: ColorScheme? = nil,
        useCustomSheet: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
   ) -> some View where Value: Identifiable {
       if #available(iOS 16.4, *), !useCustomSheet {
           sheet(
            item: optionalValue,
            onDismiss: onDismiss
           ) { _ in
               if let value = Binding(unwrap: optionalValue) {
                   content(value)
                       .presentationDetents(Set(detents.map { $0.swiftUIDetent }))
                       .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                       .presentationCornerRadius(cornerRadius)
               }
           }
       } else {
           background {
               Color.clear
                   .onDisappear {
                       MEGABottomSheet.dismiss()
                   }
                   .onChange(of: optionalValue.isPresent().wrappedValue) { show in
                       if show, let value = Binding(unwrap: optionalValue) {
                           MEGABottomSheet.present(
                            detents: detents,
                            shouldScrollExpandSheet: shouldScrollExpandSheet,
                            largestUndimmedDetent: largestUndimmedDetent,
                            showDragIndicator: showDragIndicator,
                            cornerRadius: cornerRadius,
                            showsInCompactHeight: showsInCompactHeight,
                            showNavigationBar: showNavigationBar,
                            dismissable: dismissable,
                            preferredColorScheme: preferredColorScheme
                           ) {
                               content(value)
                                   .onDisappear {
                                       optionalValue.wrappedValue = nil
                                   }
                           }
                       } else {
                           MEGABottomSheet.dismiss()
                       }
                   }
           }
       }
   }
}

// TODO: Refactor this extension to share with the same extension in MEGAPresentation
private extension Binding {
    @MainActor
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }

    @MainActor
    init?(unwrap binding: Binding<Value?>) {
        guard let wrappedValue = binding.wrappedValue
        else { return nil }

        self.init(
            get: { wrappedValue },
            set: { newValue in
                binding.wrappedValue = newValue
            }
        )
    }
}
