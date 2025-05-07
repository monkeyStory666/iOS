// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public extension MEGAList {
    func leadingNumber(_ number: Int) -> UpdatedLeadingView<MEGAListNumberAccessoryView> {
        replaceLeadingView {
            MEGAListNumberAccessoryView(number: number)
        }
    }
}

public struct MEGAListNumberAccessoryView: View {
    public var number: Int

    public var body: some View {
        Text(number.formatted())
            .font(.subheadline.bold())
            .minimumScaleFactor(0.01)
            .frame(width: 24, height: 24, alignment: .center)
            .overlay(
                Circle()
                    .stroke(TokenColors.Border.strong.swiftUI, lineWidth: 1)
            )
    }
}

#Preview {
    List {
        Group {
            MEGAListPreview()
                .leadingNumber(1)
            MEGAListPreview()
                .leadingNumber(10)
            MEGAListPreview()
                .leadingNumber(99)
            MEGAListPreview()
                .leadingNumber(100)
            MEGAListPreview()
                .leadingNumber(999)
            MEGAListPreview()
                .leadingNumber(1_000)
            MEGAListPreview()
                .leadingNumber(9_999)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    .listStyle(GroupedListStyle())
}
