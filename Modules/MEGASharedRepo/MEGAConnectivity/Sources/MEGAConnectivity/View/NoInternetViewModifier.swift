// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import SwiftUI

/// A SwiftUI `ViewModifier` to display no-internet and back-online notifications above or inline with the content.
///
/// This view modifier observes the `NoInternetViewModel` to decide when to show or hide the label.
/// It supports two layouts: `.inline` where the label is displayed above the content, and `.onTop` where the label overlays the content.
///
/// - Example Usage:
///   - Using the `.inline` layout:
///   ```swift
///   MyContentView()
///       .modifier(NoInternetViewModifier(
///           viewModel: Dependency.noInternetViewModel(
///               layout: .inline
///           )
///       ))
///   ```
///   - Using the `.onTop` layout:
///   ```swift
///   MyContentView()
///       .modifier(NoInternetViewModifier(
///           viewModel: Dependency.noInternetViewModel(
///               layout: .onTop
///           )
///       ))
///   ```
///
/// - See also:
///   - `View.noInternetViewModifier(layout:)`: A convenient extension to apply this view modifier.
///
public struct NoInternetViewModifier: ViewModifier {
    public enum Layout {
        case inline
        case onTop
    }

    public var layout: Layout = .inline
    @StateObject private var viewModel: NoInternetViewModel

    public init(
        layout: Layout = .inline,
        viewModel: @autoclosure @escaping () -> NoInternetViewModel = DependencyInjection.noInternetViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public func body(content: Content) -> some View {
        Group {
            switch layout {
            case .inline:
                VStack(spacing: 0) {
                    label
                        .clipped()
                    content
                }
            case .onTop:
                ZStack {
                    content
                    VStack {
                        label
                            .clipped()
                        Spacer()
                    }
                }
            }
        }
        .task { viewModel.onAppear() }
    }

    var label: some View {
        Group {
            switch viewModel.state {
            case .hidden:
                EmptyView()
            case .noInternet:
                MEGAPrompt(
                    title: Localizations.noInternetLocalizations.noInternetConnectionLabel,
                    type: .error
                )
            case .backOnline:
                MEGAPrompt(
                    title: Localizations.noInternetLocalizations.backOnline,
                    type: .success
                )
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

public extension View {
    /// Applies the `NoInternetViewModifier` to the view, simplifying its usage.
    ///
    /// This method provides a convenient way to apply the `NoInternetViewModifier` to a SwiftUI view. It allows specifying the layout for the no-internet notification, which can be either `.inline` or `.onTop`.
    ///
    /// - Parameters:
    ///   - layout: The layout configuration for the no-internet notification. Defaults to `.inline`.
    ///
    /// - Returns: A view modified to display no-internet and back-online notifications based on the specified layout.
    ///
    /// - Example Usage:
    ///   ```swift
    ///   MyContentView()
    ///       .noInternetViewModifier(layout: .inline)
    ///   ```
    ///
    func noInternetViewModifier(layout: NoInternetViewModifier.Layout = .inline) -> some View {
        modifier(NoInternetViewModifier(layout: layout))
    }
}
