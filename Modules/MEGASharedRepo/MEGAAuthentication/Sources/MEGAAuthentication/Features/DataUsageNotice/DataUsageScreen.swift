// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAPresentation
import MEGAUIComponent
import SwiftUI

struct DataUsageScreen: View {
    @StateObject var viewModel: DataUsageScreenViewModel

    var body: some View {
        NavigationViewStack {
            VStack(spacing: .zero) {
                DynamicScrollView {
                    VStack(alignment: .center, spacing: TokenSpacing._7) {
                        Image(.dataUsageNotice)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .frame(maxWidth: .infinity, alignment: .center)
                        VStack(alignment: .center, spacing: TokenSpacing._5) {
                            Text(.init(viewModel.title))
                                .font(.title.bold())
                                .foregroundColor(TokenColors.Text.primary.swiftUI)
                            Text(viewModel.subtitle)
                                .font(.subheadline)
                                .foregroundColor(TokenColors.Text.primary.swiftUI)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .padding(TokenSpacing._5)
                    .tint(TokenColors.Link.primary.swiftUI)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                MEGABottomAnchoredButtons(
                    buttons: [
                        MEGAButton(
                            viewModel.buttonTitle,
                            action: viewModel.didTapAgreeButton
                        )
                    ]
                )
            }
            .pageBackground()
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    closeButton
                }
            }
        }
    }

    private var closeButton: some View {
        Button(
            action: { viewModel.didTapCloseButton() },
            label: { XmarkCloseButton() }
        )
    }
}
