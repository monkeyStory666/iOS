// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

struct DeleteAccountDetailsRowView: View {
    let row: DeleteAccountDetailsRowViewModel

    var body: some View {
        HStack(
            alignment: row.isBanner ? .top: .center,
            spacing: TokenSpacing._5
        ) {
            row.image
                .resizable()
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: row.isBanner ? 8 : 2) {
                Text(row.title)
                    .font(.subheadline.bold())
                Text(row.description)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, TokenSpacing._3)
        .padding(.vertical, row.isBanner ? TokenSpacing._7 : 0)
        .padding(.horizontal, row.isBanner ? TokenSpacing._5 : 0)
        .frame(maxWidth: .infinity)
        .background(row.isBanner ? TokenColors.Notifications.notificationInfo.swiftUI : nil)
        .cornerRadius(TokenRadius.medium)
    }
}

#Preview {
    DeleteAccountDetailsRowView(
        row: .init(
            image: Image("folder", bundle: .module),
            title: "Files and folders",
            description: "All files and folders will be deleted from your account"
        )
    )
}
