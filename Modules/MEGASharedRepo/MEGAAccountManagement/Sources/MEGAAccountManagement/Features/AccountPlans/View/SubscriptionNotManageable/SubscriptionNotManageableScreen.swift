// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

struct SubscriptionNotManageableScreen: View {
    var viewModel: SubscriptionNotManageableViewModel

    init(viewModel: SubscriptionNotManageableViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.subscriptionCancelStepsGroups.count > 1 {
            twoSubscriptionsTabContent
        } else {
            singleSubscriptionCancelStepsContent
        }
    }

    private var twoSubscriptionsTabContent: some View {
        MEGATopBar(
            tabs: viewModel.subscriptionCancelStepsGroups.map {
                .init(
                    title: $0.title,
                    content: AnyView(
                        sections($0.sections)
                            .padding(.vertical, TokenSpacing._5)
                            .frame(maxWidth: .infinity)
                    )
                )
            },
            fillScreenWidth: true,
            header: {
                VStack(alignment: .leading, spacing: TokenSpacing._7) {
                    title
                        .padding(.horizontal, TokenSpacing._5)
                    subtitle
                        .padding(.horizontal, TokenSpacing._5)
                }
                .padding(.bottom, TokenSpacing._5)
            }
        )
    }

    private var singleSubscriptionCancelStepsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TokenSpacing._7) {
                title
                    .padding(.horizontal, TokenSpacing._5)
                subtitle
                    .padding(.horizontal, TokenSpacing._5)
                groups
                Spacer()
            }
        }
    }

    @ViewBuilder private var groups: some View {
        if let subscriptionCancelStepsGroup = viewModel.subscriptionCancelStepsGroups.first {
            sections(subscriptionCancelStepsGroup.sections)
        }
    }

    private var title: some View {
        Text(viewModel.title)
            .font(.title2.bold())
            .foregroundStyle(TokenColors.Text.primary.swiftUI)
    }

    private var subtitle: some View {
        Text(viewModel.subtitle)
            .font(.callout)
            .foregroundStyle(TokenColors.Text.secondary.swiftUI)
    }

    func sections(
        _ sections: [SubscriptionNotManageableViewModel.SubscriptionCancelStepsSection]
    ) -> some View {
        VStack(spacing: TokenSpacing._7) {
            ForEach(sections, id: \.title) { section in
                VStack(alignment: .leading, spacing: .zero) {
                    Text("\(section.title)")
                        .font(.callout.bold())
                        .foregroundStyle(TokenColors.Text.primary.swiftUI)
                        .padding(.horizontal, TokenSpacing._5)

                    VStack(alignment: .leading, spacing: .zero) {
                        ForEach(section.steps, id: \.index) { step in
                            stepView(for: step)
                        }
                    }
                }
            }
        }
    }

    private func stepView(for step: SubscriptionNotManageableViewModel.SubscriptionCancelStep) -> some View {
        MEGAList(title: step.text.removeAllLocalizationTags())
            .titleFont(step.titleFont)
            .titleColor(TokenColors.Text.secondary.swiftUI)
            .leadingNumber(step.index)
            .titleSubstringAttribute(
                step.text
                    .getLocalizationSubstring(tag: "B"),
                font: step.substringFont,
                foregroundColor: step.substringColor
            )
            .titleSubstringAttribute(
                step.text
                    .getLocalizationSubstring(tag: "L"),
                font: step.substringFont,
                foregroundColor: step.substringColor,
                action: { viewModel.openURL(step.link) }
            )
    }
}

#Preview {
    SubscriptionNotManageableScreen(
        viewModel: .init(
            for: .cancelThroughGoogle,
            isTrial: true
        )
    )
}
