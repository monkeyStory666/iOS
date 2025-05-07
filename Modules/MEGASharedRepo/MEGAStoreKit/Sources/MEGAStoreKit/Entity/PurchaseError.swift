// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public enum PurchaseError: Error {
    case expiredOrInvalidReceipt
    case alreadyExist
    case receiptUsed
    case generic(String)
}

extension PurchaseError: CaseIterable {
    public static var allCases: [PurchaseError] {
        [
            .expiredOrInvalidReceipt,
            .alreadyExist,
            .receiptUsed,
            .generic("")
        ]
    }
}

extension PurchaseError: Equatable {
    public static func == (lhs: PurchaseError, rhs: PurchaseError) -> Bool {
        switch (lhs, rhs) {
        case (.expiredOrInvalidReceipt, .expiredOrInvalidReceipt),
             (.alreadyExist, .alreadyExist),
             (.receiptUsed, .receiptUsed):
            return true
        case let (.generic(lhsMessage), .generic(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
