// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

struct DeleteAccountDetailsSectionView: View {
    let section: DeleteAccountDetailsSectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: TokenSpacing._7) {
            if let sectionTitle = section.title {
                Text(sectionTitle)
                    .font(.headline)
            }

            ForEach(section.rows) { row in
                DeleteAccountDetailsRowView(row: row)
            }
        }
    }
}

#Preview {
    DeleteAccountDetailsSectionView(
        section: .init(
            title: "Delete your account",
            rows: [
                .init(
                    image: Image("folder", bundle: .module),
                    title: "Files and folders",
                    description: "All files and folders will be deleted from your account"
                ),
                .init(
                    image: Image("folder", bundle: .module),
                    title: "Files and folders",
                    description: "All files and folders will be deleted from your account"
                )
            ]
        )
    )
}
