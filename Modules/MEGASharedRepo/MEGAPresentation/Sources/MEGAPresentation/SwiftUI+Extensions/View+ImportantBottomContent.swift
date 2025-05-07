// Copyright © 2023 MEGA Limited. All rights reserved.

#if !targetEnvironment(macCatalyst)
import ImpressionKit
#endif
import SwiftUI

public extension View {
    /// Marks a view as important bottom content that should be avoided by blocking UI elements (e.g., snackbars).
    ///
    /// This modifier adjusts the presentation of obstructive elements (e.g., snackbars)
    /// to prevent them from overlaying the view marked as important. It utilizes
    /// a `SecondarySceneViewModel` to manage the state and visibility of these elements.
    ///
    /// - Parameters:
    ///   - isEnabled: A Boolean value indicating whether the bottom content is currently important.
    ///                Defaults to `true`, meaning the content is considered important upon application.
    ///   - key: A unique identifier for storing and referencing the important bottom content's state in the viewModel.
    ///   - staticHeight: It will ignore the geometry reader height detection.
    ///   - secondarySceneViewModel: The view model responsible for tracking and updating the state
    ///                              of important bottom contents across the UI.
    /// - Returns: A view modified with the capability to influence the visibility of obstructive UI elements.
    func importantBottomContent(
        isEnabled: Bool = true,
        forKey key: String,
        staticHeight: CGFloat? = nil,
        in secondarySceneViewModel: SecondarySceneViewModel
    ) -> some View {
        #if !targetEnvironment(macCatalyst)
        modifier(
            ImportantBottomContentModifier(
                isEnabled: isEnabled,
                key: key, 
                staticHeight: staticHeight,
                viewModel: secondarySceneViewModel
            )
        )
        #else
        self
        #endif
    }
}

#if !targetEnvironment(macCatalyst)
private struct ImportantBottomContentModifier: ViewModifier {
    let isEnabled: Bool
    let key: String
    let staticHeight: CGFloat?

    weak var viewModel: SecondarySceneViewModel?

    private var redetectOptions: UIView.Redetect? {
        [
            .didEnterBackground,
            .leftScreen,
            .viewControllerDidDisappear,
            .willResignActive
        ]
    }

    @State private var height: CGFloat?
    @State private var isVisible = false

    init(
        isEnabled: Bool,
        key: String,
        staticHeight: CGFloat?,
        viewModel: SecondarySceneViewModel? = nil
    ) {
        self.isEnabled = isEnabled
        self.key = key
        self.staticHeight = staticHeight
        self.viewModel = viewModel
        self.height = staticHeight
    }

    func body(content: Content) -> some View {
        if staticHeight == nil {
            content.overlay(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ViewHeightKey.self, value: geometry.size.height)
                }
            )
            .onPreferenceChange(ViewHeightKey.self) { height in
                if let height, isEnabled {
                    self.height = height
                    updateInViewModel()
                }
            }
            .detectImpression(
                redetectOptions: redetectOptions,
                onChanged: contentDidChangeState
            )
        } else {
            content.detectImpression(
                redetectOptions: redetectOptions,
                onChanged: contentDidChangeState
            )
        }
    }

    private func contentDidChangeState(to newState: UIView.ImpressionState) {
        isVisible = {
            switch newState {
            case .inScreen, .impressed: return true
            default: return false
            }
        }()
        updateInViewModel()
    }

    private func updateInViewModel() {
        let height = staticHeight == nil ? height : staticHeight

        if let height, isVisible {
            withAnimation {
                viewModel?.importantBottomContents[key] = height
            }
        } else {
            withAnimation {
                viewModel?.importantBottomContents[key] = nil
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}
#endif
