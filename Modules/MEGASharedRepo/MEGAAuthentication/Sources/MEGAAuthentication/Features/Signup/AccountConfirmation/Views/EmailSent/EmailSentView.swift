// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import SwiftUI
import MEGAUIComponent
import MEGADesignToken
import MEGAConnectivity

public struct EmailSentView: View {
    @StateObject private var viewModel: EmailSentViewModel

    public init(viewModel: @autoclosure @escaping () -> EmailSentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: viewModel.didTapCloseButton) {
                        XmarkCloseButton()
                    }
                }
            }
            .maxWidthForWideScreen()
            .pageBackground(alignment: .top)
    }

    var content: some View {
        ZStack {
            DynamicScrollView {
                Group {
                    headerImage
                    bodyView
                    footer
                }
                .padding(.horizontal, TokenSpacing._5)
            }
            .allowsHitTesting(viewModel.primaryButtonState != .load)

            if viewModel.showLoading {
                LoadingScreenView()
                    .transition(.opacity)
            }
        }
    }

    var headerImage: some View {
        Image("EmailConfirmation", bundle: .module)
            .padding(.vertical, TokenSpacing._7)
    }

    var bodyView: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._5) {
            Text(viewModel.headerTitle)
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 0) {
                makeAttributedTextView(from: viewModel.descriptionTextWithEmail)
                Text(" ")
                makeAttributedTextView(from: viewModel.supportTextWithEmail)
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
        .padding(.bottom, TokenSpacing._17)
    }

    var footer: some View {
        VStack(spacing: TokenSpacing._5) {
            MEGAButton(
                viewModel.primaryButtonTitle,
                state: viewModel.primaryButtonState,
                action: viewModel.primaryButtonPressed
            )

            if let secondaryButtonTitle = viewModel.secondaryButtonTitle {
                MEGAButton(
                    secondaryButtonTitle,
                    type: .textOnly,
                    state: viewModel.secondaryButtonState,
                    action: viewModel.secondaryButtonPressed
                )
            }
        }
        .padding(.bottom, TokenSpacing._7)
    }

    private func makeAttributedTextView(from displayTextWithEmail: DisplayTextWithEmail) -> AttributedTextView {
        var action:(() -> Void)? = nil
        var font: Font = .callout.weight(.bold)
        var foregroundColor = TokenColors.Text.primary.swiftUI

        if case .link(let tapAction) = displayTextWithEmail.displayOption {
            action = tapAction
            font = .callout
            foregroundColor = TokenColors.Link.primary.swiftUI
        }

        return AttributedTextView(
            stringAttribute: .init(
                text: displayTextWithEmail.text,
                font: .callout,
                foregroundColor: TokenColors.Text.secondary.swiftUI
            ),
            substringAttributeList: [
                .init(
                    text: displayTextWithEmail.email,
                    attributes: AttributeContainer()
                        .font(font)
                        .foregroundColor(foregroundColor),
                    action: action
                )
            ]
        )
    }
}

#Preview {
    EmailSentView(viewModel: DependencyInjection.emailSentViewModel(with: EmailSentConfiguration()))
}

private final class EmailSentConfiguration: EmailSentConfigurable {
    var headerTitle: String { "headerTitle" }
    var description: String { "description" }
    var supportText: String { "supportText" }
    var primaryButtonTitle: String { "Button title" }
    var secondaryButtonTitle: String? { "Secondary button title" }
    var primaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? { nil }
    var secondaryButtonStatePublisher: AnyPublisher<MEGAButtonStyle.State, Never>? { nil }
    var showLoadingPublisher: AnyPublisher<Bool, Never>? { nil }
    var descriptionTextWithEmailUpdatePublisher: AnyPublisher<DisplayTextWithEmail, Never>? { nil }
    public var descriptionTextWithEmail: DisplayTextWithEmail {
        .init(
            text: "Description",
            email: "",
            displayOption: .none
        )
    }
}
