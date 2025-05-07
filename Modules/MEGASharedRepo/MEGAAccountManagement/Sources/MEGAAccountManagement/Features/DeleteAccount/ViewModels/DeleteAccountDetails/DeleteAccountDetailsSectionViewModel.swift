// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI
import MEGASharedRepoL10n

public struct DeleteAccountDetailsSectionViewModel: Identifiable {
    public let id = UUID()
    public let title: String?
    public let rows: [DeleteAccountDetailsRowViewModel]

    public init(title: String?, rows: [DeleteAccountDetailsRowViewModel]) {
        self.title = title
        self.rows = rows
    }
}

extension DeleteAccountDetailsSectionViewModel: Equatable {
    public static func == (
        lhs: DeleteAccountDetailsSectionViewModel, rhs: DeleteAccountDetailsSectionViewModel
    ) -> Bool {
        lhs.title == rhs.title && lhs.rows == rhs.rows
    }
}
