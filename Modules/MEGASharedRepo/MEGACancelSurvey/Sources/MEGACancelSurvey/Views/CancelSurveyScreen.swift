// Copyright © 2025 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAPresentation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct CancelSurveyScreen: View {
    @StateObject private var viewModel: CancelSurveyScreenViewModel

    @FocusState public var textFieldIsFocused

    public init(viewModel: @autoclosure @escaping () -> CancelSurveyScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationViewStack {
            VStack(spacing: .zero) {
                survey
                buttons
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        action: viewModel.didTapCloseButton,
                        label: { XmarkCloseButton() }
                    )
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { [weak viewModel] in
                        Task { await viewModel?.didTapSkip() }
                    } label: {
                        Text(SharedStrings.Localizable.CancelSurvey.skip)
                            .foregroundStyle(TokenColors.Text.primary.swiftUI)
                    }
                    .buttonStyle(.plain)
                }
            }
            .pageBackground()
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .onAppear { viewModel.onAppear() }
    }

    private var survey: some View {
        ScrollView {
            VStack(spacing: TokenSpacing._5) {
                header
                surveyOptions
                footer
            }
            .padding(.vertical, TokenSpacing._5)
        }
    }

    private var header: some View {
        VStack(alignment: .center, spacing: TokenSpacing._5) {
            Text(SharedStrings.Localizable.CancelSurvey.Header.title)
                .font(.title.bold())
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
            Text(SharedStrings.Localizable.CancelSurvey.Header.subtitle)
                .font(.subheadline)
                .foregroundStyle(TokenColors.Text.secondary.swiftUI)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, TokenSpacing._5)
    }

    private var surveyOptions: some View {
        VStack(spacing: .zero) {
            ForEach(viewModel.options) { option in
                optionRowLabel(
                    text: option.displayText,
                    isChecked: Binding(
                        get: { viewModel.isSelected(option: option) },
                        set: { _ in viewModel.didTapOption(option) }
                    )
                )
            }
            otherOptionAndField
        }
    }

    private func optionRowLabel(text: String, isChecked: Binding<Bool>) -> some View {
        MEGAList(title: text)
            .replaceLeadingView {
                MEGAChecklist(isChecked: isChecked)
            }
    }

    @ViewBuilder private var otherOptionAndField: some View {
        VStack(spacing: .zero) {
            optionRowLabel(
                text: SharedStrings.Localizable.CancelSurvey.Options.other,
                isChecked: Binding(
                    get: { viewModel.otherOptionSelected },
                    set: { _ in viewModel.didTapOtherOption() }
                )
            )
            if !viewModel.shouldHideOtherOptionInputField {
                MEGAInputField { isFocused in
                    Group {
                        if #available(iOS 16.0, *) {
                            otherOptionTextEditor
                                .scrollContentBackground(.hidden)
                        } else {
                            otherOptionTextEditor
                        }
                    }
                    .background(TokenColors.Background.page.swiftUI)
                    .focused($textFieldIsFocused)
                    .onAppear {
                        // Wait for animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            textFieldIsFocused = true
                        }
                    }
                }
                .maxCharacterLimit(
                    $viewModel.otherOptionText,
                    to: viewModel.otherOptionCharacterLimit,
                    showCounter: true
                )
                .padding(.horizontal, TokenSpacing._7)
            }
        }
    }

    @ViewBuilder private var otherOptionTextEditor: some View {
        TextEditor(text: $viewModel.otherOptionText)
            .frame(minHeight: 142)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var footer: some View {
        VStack(spacing: TokenSpacing._5) {
            Text(SharedStrings.Localizable.CancelSurvey.Footer.title)
                .multilineTextAlignment(.leading)
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                viewModel.didTapHappyToHelpCheckbox()
            } label: {
                HStack(alignment: .center, spacing: TokenSpacing._5) {
                    MEGAChecklist(isChecked: Binding(
                        get: { viewModel.happyToHelpChecked },
                        set: { _ in viewModel.didTapHappyToHelpCheckbox() }
                    ))
                    Text(SharedStrings.Localizable.CancelSurvey.Footer.subtitle)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, TokenSpacing._5)
    }

    private var buttons: some View {
        MEGABottomAnchoredButtons(
            buttons: [
                MEGAButton(
                    SharedStrings.Localizable.continue,
                    state: viewModel.continueButtonState
                ) { [weak viewModel] in
                    Task { await viewModel?.didTapContinue() }
                },
                MEGAButton(
                    SharedStrings.Localizable.CancelSurvey.dontCancel,
                    type: .secondary,
                    action: viewModel.didTapDontCancel
                )
            ],
            hidesSeparator: false
        )
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

extension CancelSurveyOption: Identifiable {
    public var id: String { text }
}
