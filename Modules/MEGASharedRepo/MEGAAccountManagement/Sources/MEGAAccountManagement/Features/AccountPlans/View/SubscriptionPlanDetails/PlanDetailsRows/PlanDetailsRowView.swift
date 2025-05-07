// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct PlanDetailsRowView: View {
    let viewModel: PlanDetailsRowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._7) {
            header
            features
            footer
            buttons
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TokenSpacing._5)
        .clipShape(
            RoundedRectangle(cornerRadius: TokenSpacing._3)
        )
        .overlay {
            RoundedRectangle(cornerRadius: TokenSpacing._3)
                .strokeBorder(TokenColors.Border.strong.swiftUI, lineWidth: 1)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._3) {
            Text(viewModel.displayName)
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
                .font(.headline.bold())

            if let dateString = viewModel.dateString {
                Text(dateString)
                    .foregroundStyle(TokenColors.Text.primary.swiftUI)
                    .font(.subheadline)
            }

            if let price = viewModel.price {
                Text(price)
                    .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                    .font(.footnote)
            }
        }
    }

    @ViewBuilder private var features: some View {
        if viewModel.features.isNotEmpty {
            VStack(alignment: .leading, spacing: TokenSpacing._5) {
                Text(SharedStrings.Localizable.SubscriptionPlanDetails.ProPlan.sectionTitle)
                    .foregroundStyle(TokenColors.Text.primary.swiftUI)
                    .font(.subheadline.bold())

                ForEach(viewModel.features) { feature in
                    MEGAList {
                        Text(feature.name)
                            .font(.subheadline)
                            .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .setPadding(.zero)
                    .leadingImage(feature.icon)
                    .leadingImageSize(.init(width: 24, height: 24))
                }
            }
        }
    }

    @ViewBuilder private var footer: some View {
        if let footerText = viewModel.footer {
            Text(footerText)
                .font(.footnote)
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder private var buttons: some View {
        let buttons = viewModel.buttons()
        if !buttons.isEmpty {
            VStack(spacing: TokenSpacing._3) {
                ForEach((0...buttons.count - 1), id: \.self) {
                    buttons[$0]
                }
            }
        }
    }
}
