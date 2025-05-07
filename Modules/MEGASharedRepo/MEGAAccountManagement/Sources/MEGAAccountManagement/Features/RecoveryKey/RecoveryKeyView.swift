// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAPresentation
import MEGASharedRepoL10n
import SwiftUI

public struct RecoveryKeyView: View {
    @StateObject private var viewModel: RecoveryKeyViewModel

    public init(
        viewModel: @autoclosure @escaping () -> RecoveryKeyViewModel = RecoveryKeyViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(spacing: TokenSpacing._7) {
            Text(.init(
                SharedStrings.Localizable.ExportRecoveryKey.information.assignLink(Constants.Link.recoveryKeyLearnMore)
            ))
            .font(.callout)
            .foregroundColor(TokenColors.Text.secondary.swiftUI)
            .tint(TokenColors.Link.primary.swiftUI)
            recoveryKeyField
            Text(SharedStrings.Localizable.ExportRecoveryKey.or)
                .font(.callout)
                .foregroundColor(TokenColors.Text.secondary.swiftUI)
                .frame(maxWidth: .infinity, alignment: .center)
            MEGAButton(
                SharedStrings.Localizable.ExportRecoveryKey.saveToDevice,
                state: viewModel.saveButtonState
            ) {
                viewModel.didTapSaveToDevice()
            }
        }
        .padding(.horizontal, TokenSpacing._5)
        #if targetEnvironment(macCatalyst)
        .fullScreenCover(unwrap: $viewModel.isSavingTextFile) { itemToShare in
            ZStack(alignment: .center) {
                ShareSheetView(
                    itemsToShare: [itemToShare.wrappedValue]
                ) { isCompleted in
                    viewModel.didDismissSaveSheet(isCompleted: isCompleted)
                }
                ProgressView()
            }
        }
        #else
        .sheet(unwrap: $viewModel.isSavingTextFile) {
            ShareSheetView(
                itemsToShare: [$0.wrappedValue]
            ) { isCompleted in
                viewModel.didDismissSaveSheet(isCompleted: isCompleted)
            }
        }
        #endif
    }

    var recoveryKeyField: some View {
        MEGAFormRow(SharedStrings.Localizable.ExportRecoveryKey.copyYourRecoveryKey) {
            MEGAInputField { _ in
                HStack {
                    Text(viewModel.recoveryKeyText)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shimmering(active: !viewModel.state.isLoaded)
                }
            } accessoryBuilder: { _ in
                if viewModel.shouldShowCopyButton {
                    Button(action: {
                        viewModel.didTapCopy()
                    }, label: {
                        Image("CopyMediumThinOutline", bundle: .module)
                            .foregroundColor(TokenColors.Icon.secondary.swiftUI)
                    })
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }
}
