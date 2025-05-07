// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

struct ListSectionView: View {
    @StateObject private var viewModel: ListSectionViewModel

    init(viewModel: @autoclosure @escaping () -> ListSectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        if viewModel.isHidden {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                if viewModel.shouldDisplayTitle {
                    Text(viewModel.title)
                        .font(.subheadline.bold())
                        .foregroundColor(TokenColors.Text.secondary.swiftUI)
                        .padding(.horizontal, TokenSpacing._5)
                }
                viewModel.rows.rowViews
            }
        }
    }
}
