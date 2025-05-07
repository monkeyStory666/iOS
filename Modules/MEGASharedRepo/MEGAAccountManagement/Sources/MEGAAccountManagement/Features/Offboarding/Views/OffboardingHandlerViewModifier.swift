// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

public struct OffboardingHandlerViewModifier: ViewModifier {
    @StateObject private var viewModel: OffboardingViewModel

    public init(
        viewModel: @autoclosure @escaping () -> OffboardingViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public func body(content: Content) -> some View {
        content
            .dynamicSheet(isPresented: $viewModel.isPresented) { _ in
                OffboardingView(viewModel: viewModel)
            }
    }
}
