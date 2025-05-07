// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

public struct DeleteAccountDetailsRowViewModel: Identifiable {
    public let id = UUID()
    public let image: Image
    public let title: String
    public let description: String
    public let isBanner: Bool

    public init(image: Image, title: String, description: String, isBanner: Bool = false) {
        self.image = image
        self.title = title
        self.description = description
        self.isBanner = isBanner
    }
}

extension DeleteAccountDetailsRowViewModel: Equatable {
    public static func == (
        lhs: DeleteAccountDetailsRowViewModel, rhs: DeleteAccountDetailsRowViewModel
    ) -> Bool {
        lhs.image == rhs.image
        && lhs.title == rhs.title
        && lhs.description == rhs.description
        && lhs.isBanner == rhs.isBanner
    }
}
