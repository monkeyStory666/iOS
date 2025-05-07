// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGAAuthentication
import MEGADesignToken
import MEGAPresentation
import MEGASwift
import MEGAUIComponent
import SwiftUI

public struct WhatsNewScreen: View {
    @StateObject var viewModel: WhatsNewScreenViewModel

    public init(viewModel: @autoclosure @escaping () -> WhatsNewScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        MEGAPromotionalDialog(
            headerView: { imageHeaderView },
            headlineText: viewModel.config.headlineText,
            smallTitleText: viewModel.config.smallTitleText,
            bodyText: viewModel.config.bodyText,
            textAlignment: viewModel.config.textAlignment,
            ignoreSafeAreaEdges: viewModel.ignoresSafeAreaEdges,
            hasCloseButtonOverlay: viewModel.config.imageDisplayMode.isFillScreenWidth,
            footerView: { footerView },
            dismissAction: dismissAction
        )
        .listContent { listContentView }
        .primaryButton(
            MEGAButton(
                viewModel.config.primaryButtonText,
                type: .primary,
                action: viewModel.primaryButtonAction
            )
        )
        .secondaryButton(
            MEGAButton(
                viewModel.config.secondaryButtonText,
                type: .secondary,
                action: viewModel.secondaryButtonAction
            )
        )
    }

    var dismissAction: (() -> Void)? {
        #if targetEnvironment(macCatalyst)
        viewModel.dismiss
        #else
        viewModel.config.hasDismissButton ? viewModel.dismiss : nil
        #endif
    }

    @ViewBuilder private var listContentView: some View {
        if viewModel.config.rows.isNotEmpty {
            VStack(spacing: TokenSpacing._5) {
                ForEach(viewModel.config.rows, id: \.title) { row in
                    MEGAList(
                        title: row.title,
                        subtitle: row.subtitle
                    )
                    .leadingImage(icon: row.image)
                }
            }
        }
    }

    @ViewBuilder private var footerView: some View {
        if let footerText = viewModel.config.footerText {
            MEGAPromotionalDialogTextFooter(text: footerText)
        }
    }

    @ViewBuilder private var imageHeaderView: some View {
        switch viewModel.config.imageDisplayMode {
        case .regular(let image):
            MEGAPromotionalDialogImageHeader(image: image)
        case .small(let image):
            MEGAPromotionalDialogIllustrationHeader(illustration: image)
        case .fillScreenWidth(let image):
            MEGAPromotionalDialogFullImageHeader(
                image: image,
                backgroundColor: TokenColors.Button.secondary.swiftUI
            )
        case .hidden:
            EmptyView()
        }
    }
}
